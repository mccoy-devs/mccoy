def iqtree_random_seed(wildcards):
    seed = os.environ.get("IQTREE_SEED", False)
    return f"-seed {seed}" if seed else ""


rule tree:
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
    threads: config["tree"]["threads"]
    resources:
        **config['tree']['resources'],
    shell:
        """
        iqtree2 -s {input} -st DNA -pre {params.pre} {params.config} {params.seed} -ntmax {threads} 2>&1 > {log}
        """


rule render_mltree:
    """
    Renders the maximum likelihood tree from iqtree in SVG and HTML format.
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
