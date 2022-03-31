rule combine:
    input:
        gisaidr=lambda wildcards: RESOURCES_DIR / "{id}-original.fasta" if config['query']['enabled'] else [],
        extra=INPUT_DIR.glob("*.fasta"),
    output:
        RESOURCES_DIR / "{id}-combined.fasta",
    log:
        LOG_DIR / "combine-{id}.fasta",
    shell:
        """
        cat {input.gisaidr} {input.extra} | sed s/\@/_/g > {output}
        """
