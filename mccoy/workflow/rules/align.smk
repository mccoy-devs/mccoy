rule align:
    input:
        original="data/combined/{id}.fasta",
        reference=RESOURCES_DIR / "reference.fasta",
    output:
        "results/aligned/{id}.fasta",
    log:
        "logs/align-{id}.txt",
    conda:
        "../envs/mafft.yml"
    params:
        lambda wildcards: " ".join(config["align"]["mafft"]),
    threads: lambda wildcards: config["align"]["threads"] if config["align"]["threads"] else workflow.cores
    resources:
        **config["align"]["resources"],
    shell:
        """
        REFNAME=$(head -n1 {input.reference} | tr -d '>')
        mafft --thread {threads} {params} {input.original} {input.reference} 2> {log} \
            | seqkit grep -rvip "^$REFNAME" > {output} 2> {log}
        """
