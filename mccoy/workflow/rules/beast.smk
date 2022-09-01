

rule onlinebeast:
    """
    Use `online-beast <https://github.com/Wytamma/online-beast>`_ to add any new
    sequences to the Beast2 analysis from an inherited run and update the state.

    .. warning::
        This rule will only run if the ``--inherit`` or ``--inherit-last`` flags are passed to McCoy.


    :input xml:        the template file generated by the :smk:ref:`dynamicbeast` rule
    :input state:      the statefile from the inherited McCoy run.
                       This is compied into the ``data`` directory by the McCoy CLI.
    :input alignment:  the aligned sequences from the :smk:ref:`align` rule

    :output:           the updated state file produced by online-beast.

                       **Note:** No XML file is produced as we are using a template XML which
                       doesn't actually contain the sequences in it.
    """
    input:
        xml=rules.dynamicbeast.output,
        state="data/{id}-beast.xml.state",
        alignment=rules.align.output,
    output:
        "results/beast/{id}-online_beast.xml.state",
    log:
        "logs/{id}-onlinebeast.log",
    conda:
        "../envs/beast.yml"
    params:
        lambda wildcards, output: expand(output, **wildcards)[0].rstrip(".state"),
    shell:
        """
        online-beast {input.xml} {input.alignment} --state-file {input.state} --output {params} --template --no-date-trait
        """


def beast_params(wildcards):
    params = [v for v in config["beast"]["beast"]]
    if config['inherit']:
        params.append("-resume")
    return " ".join(params)


print(config['beast'])


rule beast:
    """
    Run Beast2, either restarting from a state file or from scratch.

    .. note::
        GPU acceleration is requested if available by default. If you are running on a machine with a compatible GPU then
        the code will crash when using the bioconda package. To avoid this, either:

        1. ensure you pass ``--use-envmodules`` to McCoy and set the ``envmodules`` directives of this rule appropriately, or
        2. remove the ``-beagle_GPU`` flag from the  ``beast.beast`` entry in your McCoy config file. 

    :input alignment:         the aligned fasta file output from :smk:ref:`align`
    :input template:          the Beast 2 input XML file, templated with `feast <https://github.com/tgvaughan/feast>`_.
                              If ``inherit`` is set in the config then the output of the :smk:ref:`onlinebeast` rule is used,
                              otherwise the output of the :smk:ref:`dynamicbeast` rule is used.

    :output:                  the tree log, trace log, and statefile from Beast2

    :config inherit:          are we inheriting from a previous run?
    :config beast.dynamic:    the dynamic variables used to populate the feast template.
    :config beast.beast:      Beast2 command line arguments to pass (beyond the params, statefile and input)
    :config beast.threads:    the number of cores to run with (both locally or when submitting to a cluster)
    :config beast.resources:  the resources to request when submitting to a cluster

    :envmodules:              environment variables to load for the Spartan HPC system

    ..note::
        GPU acceleration is **not** requested by default. If you are running on a machine with a compatible GPU then
        please replace ``-beagle`` with ``-beagle_GPU`` in the ``beast.beast`` entry in your McCoy ``config.yaml`` file.
    """
    input:
        alignment=rules.align.output,
        template=rules.dynamicbeast.output,
        statefile=rules.onlinebeast.output if config['inherit'] else [],
    output:
        treelog="results/beast/{id}-tree.log",
        tracelog="results/beast/{id}-trace.log",
        statefile="results/beast/{id}-beast.xml.state",
    log:
        "logs/{id}_beast.log",
    conda:
        "../envs/beast.yml"
    params:
        dynamic=lambda wildcards: ",".join(config["beast"]["dynamic"]),
        beast=beast_params,
    threads: config["beast"].get("threads", workflow.cores)
    resources:
        **config["beast"].get("resources", {}),
    envmodules:
        *config["beast"].get("envmodules", []),
    shell:
        """
        if [[ -n "{input.statefile}" ]]; then cp {input.statefile} {output.statefile}; fi
        beast -D 'alignment={input.alignment},tracelog={output.tracelog},treelog={output.treelog},mcmc.threads={threads},{params.dynamic}' {params.beast} -statefile {output.statefile} {input.template} 1>&2 2> {log}
        """


rule plot_traces:
    """
    Makes trace plots from the beast log file.
    """
    input:
        expand(rules.beast.output.tracelog, id=config['id']),
    output:
        directory("results/traces/")
    conda:
        "../envs/plot_traces.yml"
    shell:
        """
        python {SCRIPT_DIR}/plot_traces.py {input} {output}
        """


rule arviz:
    """
    Makes trace plots from the beast log file.
    """
    input:
        expand(rules.beast.output.tracelog, id=config['id']),
    output:
        summary_html="results/beast/{id}-summary.html",
        posterior_svg="results/beast/{id}-posterior.svg",
        pairplot_svg="results/beast/{id}-pairplot.svg",
    conda:
        "../envs/arviz.yml"
    shell:
        """
        python {SCRIPT_DIR}/arviz_output.py {input} {output.summary_html} {output.posterior_svg} {output.pairplot_svg}
        """


rule max_clade_credibility_tree:
    """
    Makes trace plots from the beast log file.
    """
    input:
        expand(rules.beast.output.treelog, id=config['id']),
    output:
        "results/beast/{id}-maxcladecredibility.treefile",
    conda:
        "../envs/beast.yml"
    shell:
        """
        treeannotator -heights mean {input} {output}
        """


rule max_clade_credibility_tree_newick:
    """
    Makes trace plots from the beast log file.
    """
    input:
        expand(rules.max_clade_credibility_tree.output, id=config['id']),
    output:
        "results/beast/{id}-maxcladecredibility.nwk",
    conda:
        "../envs/dendropy.yml"
    shell:
        "python {SCRIPT_DIR}/tree_converter.py {input} {output} --node-label posterior"


rule max_clade_credibility_tree_render:
    """
    Renders the consensus maximum likelihood tree from iqtree in SVG and HTML format.
    """
    input:
        expand(rules.max_clade_credibility_tree_newick.output, id=config['id']),
    output:
        svg="results/beast/{id}-maxcladecredibility.svg",
        html="results/beast/{id}-maxcladecredibility.html",
    conda:
        "../envs/toytree.yml"
    shell:
        "python {SCRIPT_DIR}/render_tree.py {input} --svg {output.svg} --html {output.html}"
