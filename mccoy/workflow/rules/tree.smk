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
    threads: lambda wildcards: config["tree"]["threads"] if config["tree"]["threads"] else workflow.cores
    resources:
        **config['tree']['resources'],
    shell:
        """
        iqtree2 -s {input} -st DNA -pre {params.pre} {params.config} -ntmax {threads} 2>&1 > {log}
        """
