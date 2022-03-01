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
    shell:
        """
        REFNAME=$(head -n1 {input.original} | tr -d '>')
        mafft {params} {input.original} {input.reference} \
            | seqkit grep -rvip "^$REFNAME" > {output}
        """
