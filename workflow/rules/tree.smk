rule tree:
    input:
        RESULTS_DIR / "{id}-aligned.fasta",
    output:
        multiext(str(RESULTS_DIR / "{id}-aligned.fasta"),
                ".treefile", ".bionj", ".ckp.gz", ".contree",
                ".iqtree", ".log", ".mldist", ".splits.nex", ".uniqueseq.phy")
    conda:
        SNAKE_DIR / "envs/iqtree.yml"
    log:
        RESULTS_DIR / "logs/tree-{id}.txt"
    params:
        lambda wildcards: " ".join(config["tree"]["iqtree2"])
    shell:
        "iqtree2 -s {input} -st DNA -pre {input} {params}"
