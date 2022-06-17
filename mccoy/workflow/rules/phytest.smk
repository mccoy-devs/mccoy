rule phytest:
    input:
        alignment="results/aligned/{id}.fasta",
        tree="results/tree/{id}.fasta.treefile",
        phytest_file=PROJECT_DIR / "tests.py",
    output:
        "results/{id}-phytest.html",
    log:
        "logs/phytest-{id}.log",
    conda:
        "envs/phytest.yml"
    shell:
        """
        phytest {input.phytest_file} -a {input.alignment} -t {input.tree} --report {output} -v > {log}
        """
