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
    shell:
        "iqtree2 -s {input} -st DNA -pre {input} -nt AUTO -m HKY+G -bb 1000"

