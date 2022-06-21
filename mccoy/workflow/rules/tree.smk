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
        lambda wildcards: " ".join(config["tree"]["iqtree2"]),
    threads: lambda wildcards: config["tree"]["threads"] if config["tree"]["threads"] else workflow.cores
    resources:
        **config['tree']['resources'],
    shell:
        f"iqtree2 -s {{input}} -st DNA -pre {Path(output[0]).stem} {{params}} -ntmax {{threads}}"
