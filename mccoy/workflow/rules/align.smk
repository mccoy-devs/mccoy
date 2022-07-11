rule align:
    """
    Use `MAFFT <https://github.com/GSLBiotech/mafft>`_ to align the combined sequence file against the project
    reference.

    :input original:
        the combined sequence file generated from the :smk:ref:`combine` rule
    :input reference:
        the project reference sequence, provided during McCoy project creation

    :config align.mafft:
        (optional) a list of command line arguments passed directly to MAFFT
    :config align.threads:
        (optional) the number of threads (cores) to use for a single MAFFT call
    :config align.resources:
        (optional) the resources to request when submitting to a cluster

    :output:
        the aligned version of the original input file
    :params:
        the command-line arguments passed to MAFFT (set in `align.mafft` config entry)
    :threads:
        set to `align.threads` from the config file if present, else set by the number of cores available to the
        workflow
    :resources:
        set to `align.resources` in the project config, if present
    """
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
