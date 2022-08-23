rule combine:
    """
    Combine multiple sequence files together into a single file.

    :input data: the sequence files to be concatenated 
    :output:     a single concatenated fasta file
    """
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
        cat {input.data} | sed s/\@/_/g | seqkit rmdup -n -o {output} 2> {log}
        """
