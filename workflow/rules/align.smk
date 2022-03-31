rule align:
    input:
        original=RESOURCES_DIR / "{id}-combined.fasta",
        reference=RESOURCES_DIR / "reference.fasta",
    output:
        RESULTS_DIR / "{id}-aligned.fasta",
    conda:
        SNAKE_DIR / "envs/mafft.yml"
    log:
        LOG_DIR / "align-{id}.txt",
    params:
        lambda wildcards: " ".join(config["align"]["mafft"]),
    threads: 4
    resources:
        time="00:10:00",
        mem="8G",
        cpus=4,
    shell:
        """
        REFNAME=$(head -n1 {input.reference} | tr -d '>')
        mafft --thread {threads} {params} {input.original} {input.reference} \
            | seqkit grep -rvip "^$REFNAME" > {output}
        """
