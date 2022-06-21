rule align:
    input:
        original=DATA_DIR / "combined/{id}.fasta",
        reference=RESOURCES_DIR / "reference.fasta",
    output:
        RESULTS_DIR / "aligned/{id}.fasta",
    conda:
        SNAKE_DIR / "envs/mafft.yml"
    log:
        LOG_DIR / "align-{id}.txt",
    params:
        lambda wildcards: " ".join(config["align"]["mafft"]),
    threads: lambda wildcards: config["align"]["threads"] if config["align"]["threads"] else workflow.cores
    resources:
        **config["align"]["resources"],
    shell:
        """
        REFNAME=$(head -n1 {input.reference} | tr -d '>')
        mafft --thread {threads} {params} {input.original} {input.reference} \
            | seqkit grep -rvip "^$REFNAME" > {output}
        """
