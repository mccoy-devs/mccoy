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


    