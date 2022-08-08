rule onlinebeast:
    input:
        xml=rules.dynamicbeast.output,
        alignment=rules.align.output,
    output:
        "results/beast/{id}-online_beast.xml",
    log:
        "logs/{id}-onlinebeast.log",
    conda:
        "../envs/beast.yml"
    shell:
        """
        online-beast {input.xml} {input.alignment} --state-file data/{wildcards.id}-beast.xml.state --output {output} --template --no-date-trait
        """


rule beast:
    """
    Run Beast2, either restarting from a state file or from scratch.

    :input alignment:         the aligned fasta file output from :smk:rule:`align`
    :input template:          the Beast 2 input XML file, templated with `feast <https://github.com/tgvaughan/feast>`_.
                              If ``inherit`` is set in the config then the output of the :smk:rule:`onlinebeast` rule is used,
                              otherwise the output of the :smk:rule:`dynamicbeast` rule is used.
    :output:                  the tree log, trace log, and statefile from Beast2
    :config inherit:          are we inheriting from a previous run?
    :config beast.dynamic:    the dynamic variables used to populate the feast template.
    :config beast.beast:      Beast2 command line arguments to pass (beyond the params, statefile and input)
    :config beast.threads:    the number of cores to run with (both locally or when submitting to a cluster)
    :config beast.resources:  the resources to request when submitting to a cluster
    :envmodules:              environment variables to load for the Spartan HPC system

    Note
    ----
    GPU acceleration is requested if available by default. If you are running on a machine with a compatible GPU then
    the code will crash when using the bioconda package. To avoid this, either:

    1. ensure you pass ``--use-envmodules`` to McCoy and set the ``envmodules`` directives of this rule appropriately, or
    2. remove the ``-beagle_GPU`` flag from the  ``beast.beast`` entry in your McCoy config file. 
    """
    input:
        alignment=rules.align.output,
        template=rules.onlinebeast.output if config['inherit'] else rules.dynamicbeast.output,
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
        beast=lambda wildcards: " ".join(config["beast"]["beast"]),
    threads: config["beast"]["threads"]
    resources:
        **config["beast"].get("resources", {}),
    envmodules:
        *config["beast"].get("envmodules", []),
    shell:
        """
        beast -D 'alignment={input.alignment},tracelog={output.tracelog},treelog={output.treelog},mcmc.threads={threads},{params.dynamic}' {params.beast} -statefile {output.statefile} {input.template} 1>&2 2> {log}
        """
