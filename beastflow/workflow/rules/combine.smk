rule combine:
    input:
        data=INPUT_DATA,
    output:
        DATA_DIR / "{id}-combined.fasta",
    conda:
        SNAKE_DIR / "envs/combine.yml"
    log:
        LOG_DIR / "combine-{id}.fasta",
    shell:
        """
        cat {input.data} | sed s/\@/_/g | seqkit rmdup -n -o {output}
        """
