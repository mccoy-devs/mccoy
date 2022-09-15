def iqtree_random_seed(wildcards):
    seed = os.environ.get("IQTREE_SEED", False)
    return f"-seed {seed}" if seed else ""


rule tree:
    """
    Use `iqtree <http://www.iqtree.org>`_ to generate the maximum likelihood phylogenomic tree.

    :input:   the aligned fasta file from the :smk:ref:`align` rule
    :output:  the files output by iqtree, most notably `*.treefile`

    :config tree.iqtree2:    the iqtree config parameters passed on the command line

                             **Note:** `-pre` is set automatically by McCoy.
                             `-seed` will also be take on the value of the environment variable `IQTREE_SEED` if set.

    :config tree.threads:    the maximum number of threads available to iqtree
    :config tree.resources:  the resources to request when submitting this rule to a cluster
    """
    input:
        "results/aligned/{id}.fasta",
    output:
        multiext(
            "results/tree/{id}.fasta",
            ".treefile",
            ".bionj",
            ".ckp.gz",
            ".contree",
            ".iqtree",
            ".log",
            ".mldist",
            ".splits.nex",
        ),
    log:
        "logs/tree-{id}.txt",
    conda:
        "../envs/iqtree.yml"
    params:
        config=lambda wildcards: " ".join(config["tree"]["iqtree2"]),
        pre=lambda wildcards, output: Path(output[0]).with_suffix(''),
        seed=iqtree_random_seed,
    threads: config["tree"].get("threads", config["all"]["threads_max"])
    resources:
        **config['tree'].get('resources', {}),
    shell:
        """
        iqtree2 -s {input} -st DNA -pre {params.pre} {params.config} {params.seed} -ntmax {threads} 2>&1 > {log}
        """


rule render_mltree:
    """
    Renders the maximum likelihood tree from iqtree in SVG and HTML format.

    :input:  the tree file produced by the :smk:ref:`tree` rule

    :output svg:   the maximum likeihood tree (svg)
    :output html:  the maximum likeihood tree (html)
    """
    input:
        "results/tree/{id}.fasta.treefile",
    output:
        svg="results/tree/{id}-mltree.svg",
        html="results/tree/{id}-mltree.html",
    conda:
        "../envs/toytree.yml"
    log:
        "logs/render_tree-{id}.txt",
    shell:
        "python {SCRIPT_DIR}/render_tree.py {input} --svg {output.svg} --html {output.html}"


rule render_consensus_mltree:
    """
    Renders the consensus maximum likelihood tree from iqtree in SVG and HTML format.
    """
    input:
        "results/tree/{id}.fasta.contree",
    output:
        svg="results/tree/{id}-consensus-mltree.svg",
        html="results/tree/{id}-consensus-mltree.html",
    conda:
        "../envs/toytree.yml"
    shell:
        "python {SCRIPT_DIR}/render_tree.py {input} --svg {output.svg} --html {output.html}"
