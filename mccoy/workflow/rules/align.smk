rule align:
    """
    Use `MAFFT <https://github.com/GSLBiotech/mafft>`_ to align the combined sequence file against the project
    reference.

    :input original:   the combined sequence file generated from the :smk:ref:`combine` rule
    :input reference:  the project reference sequence, provided during McCoy project creation

    :config align.mafft:      a list of command line arguments passed directly to MAFFT
    :config align.threads:    the number of threads (cores) to use for a single MAFFT call
    :config align.resources:  the resources to request when submitting to a cluster

    :output:     the aligned version of the original input file
    :params:     the command-line arguments passed to MAFFT (set in `align.mafft` config entry)
    :threads:    set to `align.threads` from the config file if present, else set by the number of cores available to the workflow (up-to `threads_max`)
    :resources:  set to `align.resources` in the project config, if present
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
    threads: config["align"].get("threads", config["all"]["threads_max"])
    resources:
        **config["align"].get("resources", {}),
    shell:
        """
        REFNAME=$(head -n1 {input.reference} | tr -d '>')
        mafft --thread {threads} {params} {input.original} {input.reference} 2> {log} \
            | seqkit grep -rvip "^$REFNAME" > {output} 2> {log}
        """


rule alignment_stats:
    input:
        alignment=rules.align.output,
        reference=RESOURCES_DIR / "reference.fasta",
    conda:
        "../envs/steenwyk.yml"
    output:
        summary="results/aligned/{id}.summary.txt",
        gc_content="results/aligned/{id}.gc_content.txt",
        relative_composition_variability="results/aligned/{id}.relative_composition_variability.txt",
        pairwise_identity="results/aligned/{id}.pairwise_identity.txt",
        pairwise_identity_verbose="results/aligned/{id}.pairwise_identity_verbose.txt",
        # position_specific_score_matrix="results/aligned/{id}.position_specific_score_matrix.txt",
        # sum_of_pairs_score="results/aligned/{id}.sum_of_pairs_score.txt",
    shell:
        """
        biokit alignment_summary {input.alignment} > {output.summary}
        phykit gc_content {input.alignment} > {output.gc_content}
        phykit relative_composition_variability {input.alignment} > {output.relative_composition_variability}
        phykit pairwise_identity {input.alignment} > {output.pairwise_identity}
        phykit pairwise_identity {input.alignment} --verbose > {output.pairwise_identity_verbose}

        # phykit sum_of_pairs_score {input.alignment} --reference {input.reference} > output.sum_of_pairs_score
        # biokit position_specific_score_matrix {input.alignment}  > output.position_specific_score_matrix
        """


rule pairwise_identity_histogram:
    input:
        rules.alignment_stats.output.pairwise_identity_verbose,
    conda:
        "../envs/plot_traces.yml"
    output:
        svg="results/aligned/{id}.pairwise_identity_verbose.svg",
        html="results/aligned/{id}.pairwise_identity_verbose.html",
    shell:
        """
        python {SCRIPT_DIR}/pairwise_identity_histogram.py {input} {output.svg} {output.html}
        """
