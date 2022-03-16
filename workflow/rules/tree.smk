rule tree:
    input:
        RESULTS_DIR / "{id}-aligned.fasta",
    output:
        multiext(str(RESULTS_DIR / "{id}-aligned.fasta"),
                ".treefile", ".bionj", ".ckp.gz", ".contree",
                ".iqtree", ".log", ".mldist", ".splits.nex")
    conda:
        SNAKE_DIR / "envs/iqtree.yml"
    log:
        RESULTS_DIR / "logs/tree-{id}.txt"
    params:
        lambda wildcards: " ".join(config["tree"]["iqtree2"])
    threads: 32
    resources:
        time = "02:00:00",
        mem = "64G",
        cpus = 32
    shell:
        "iqtree2 -s {input} -st DNA -pre {input} {params}"
