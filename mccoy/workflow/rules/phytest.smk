rule phytest:
    input:
        alignment="results/aligned/{id}.fasta",
        tree="results/tree/{id}.fasta.treefile",
        phytest_file=PROJECT_DIR / "tests.py",
    output:
        report("results/{id}-phytest.html", category="Quality Control"),
    log:
        "logs/phytest-{id}.log",
    conda:
        "../envs/phytest.yml"
    shell:
        """
        phytest {input.phytest_file} -s {input.alignment} -t {input.tree} --report {output} -v > {log}
        """
