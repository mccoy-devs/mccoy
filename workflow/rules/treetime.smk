rule dates:
    input:
        "results/{id}-aligned.fasta.treefile",
    output:
        "results/{id}-dates.csv"
    conda:
        "../envs/treetime.yml"
    log:
        LOG_DIR / "dates-{id}.txt"
    shell:
        "python "+str(SNAKE_DIR)+"/scripts/dates.py {input} {output}"

rule treetime:
    input:
        treefile = "results/{id}-aligned.fasta.treefile",
        alignment = "results/{id}-aligned.fasta",
        dates = "results/{id}-dates.csv"
    output:
        multiext(str("results/{id}-treetime/" ),
                "rerooted.newick", "rtt.csv", "root_to_tip_regression.pdf")
    conda:
        "../envs/treetime.yml"
    log:
        LOG_DIR / "roottotip-{id}.txt"
    shell:
        """
        treetime clock --tree {treefile} --dates {dates} --aln {alignment} --outdir {RESULTS_DIR/"{id}-treetime"}
        """
