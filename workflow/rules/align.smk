rule align:
    input:
        RESOURCES_DIR / "{id}-original.fasta"
    output:
        RESULTS_DIR / "{id}-aligned.fasta"
    conda:
        SNAKE_DIR / "envs/mafft.yml"
    log:
        LOG_DIR / "align-{id}.txt"
    shell:
        """
        REFNAME=$(head -n1 {input} | tr -d '>')
        mafft --6merpair --keeplength --addfragments {input} data/reference.fasta \
            | seqkit grep -rvip "^$REFNAME" > {output}
        """
