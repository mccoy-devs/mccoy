rule dates:
    input:
        RESULTS_DIR / "{id}-aligned.fasta.treefile",
    output:
        RESULTS_DIR / "{id}-dates.csv"
    conda:
        SNAKE_DIR / "envs/treetime.yml"
    log:
        LOG_DIR / "dates-{id}.txt"
    script:
        "{SNAKE_DIR}/scripts/dates.py"

rule treetime:
    input:
        treefile = RESULTS_DIR / "{id}-aligned.fasta.treefile",
        alignment = RESULTS_DIR / "{id}-aligned.fasta",
        dates = RESULTS_DIR / "{id}-dates.csv"
    output:
        multiext(str(RESULTS_DIR / "{id}-treetime/" ),
                "rerooted.newick", "rtt.csv", "root_to_tip_regression.pdf")
    conda:
        SNAKE_DIR / "envs/treetime.yml"
    log:
        LOG_DIR / "roottotip-{id}.txt"
    shell:
        """
        treetime clock --tree {treefile} --dates {dates} --aln {alignment} --outdir {RESULTS_DIR/"{id}-treetime"}
        """
