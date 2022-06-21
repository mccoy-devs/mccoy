rule tree:
    input:
        RESULTS_DIR / "aligned/{id}.fasta",
    output:
        multiext(
            str(RESULTS_DIR / "tree/{id}.fasta"),
            ".treefile",
            ".bionj",
            ".ckp.gz",
            ".contree",
            ".iqtree",
            ".log",
            ".mldist",
            ".splits.nex",
        ),
    conda:
        SNAKE_DIR / "envs/iqtree.yml"
    log:
        RESULTS_DIR / "logs/tree-{id}.txt",
    params:
        config=lambda wildcards: " ".join(config["tree"]["iqtree2"]),
        pre=lambda wildcards, output: Path(output[0]).with_suffix(''),
    threads: lambda wildcards: config["tree"]["threads"] if config["tree"]["threads"] else workflow.cores
    resources:
        **config['tree']['resources'],
    shell:
        """
        iqtree2 -s {input} -st DNA -pre {params.pre} {params.config} -ntmax {threads}
        """
