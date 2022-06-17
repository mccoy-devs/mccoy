rule combine:
    input:
        data=INPUT_DATA,
    output:
        "data/combined/{id}.fasta",
    log:
        "logs/combine-{id}.fasta",
    conda:
        "../envs/combine.yml"
    shell:
        """
        cat {input.data} | sed s/\@/_/g | seqkit rmdup -n -o {output}
        """
