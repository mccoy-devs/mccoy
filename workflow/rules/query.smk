rule query:
    output:
        RESOURCES_DIR / "{id}-original.fasta"
    conda:
        SNAKE_DIR / "envs/gisaidr.yml"
    log:
        LOG_DIR / "query-{id}.txt"
    params:
        basename = lambda wildcards: RESOURCES_DIR / wildcards.id,
    shell:
        "Rscript {SNAKE_DIR}/scripts/gisaidr-fetch_example.R {params.basename} {DOWNSAMPLE}"

# vim: set ft=snakemake:
