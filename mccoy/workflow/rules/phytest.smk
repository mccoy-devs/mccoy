rule phytest:
    input:
        alignment=RESULTS_DIR / "{id}-aligned.fasta",
        tree=RESULTS_DIR / "{id}-aligned.fasta.treefile",
        phytest_file=PROJECT_DIR / "tests.py",
    output:
        RESULTS_DIR / "{id}-phytest.html",
    conda:
        SNAKE_DIR / "envs/phytest.yml"
    log:
        LOG_DIR / "phytest-{id}.log",
    shell:
        """
        phytest {input.phytest_file} -a {input.alignment} -t {input.tree} --report {output} -v > {log}
        """
