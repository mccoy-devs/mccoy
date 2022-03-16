rule align:
    input:
        original = RESOURCES_DIR / "{id}-original.fasta",
        reference = RESOURCES_DIR / "reference.fasta"
    output:
        RESULTS_DIR / "{id}-aligned.fasta"
    conda:
        SNAKE_DIR / "envs/mafft.yml"
    log:
        LOG_DIR / "align-{id}.txt"
    params:
        lambda wildcards: " ".join(config["align"]["mafft"])
    threads: 8
    resources:
        time = "01:00:00"
        mem = "16G"
        cpus = 8
    shell:
        """
        REFNAME=$(head -n1 {input.original} | tr -d '>')
        mafft --thread {threads} {params} {input.original} {input.reference} \
            | seqkit grep -rvip "^$REFNAME" > {output}
        """
