import yaml


rule query:
    output:
        fasta=RESOURCES_DIR / "{id}-original.fasta",
    conda:
        SNAKE_DIR / "envs/gisaidr.yml"
    log:
        LOG_DIR / "query-{id}.txt",
    params:
        basename=lambda wildcards: RESOURCES_DIR / wildcards.id,
        conf=lambda wildcards: yaml.dump(config["query"]),
        conf_fname=temp(RESULTS_DIR / "gisaidr_params.yml"),
    shell:
        """
        echo \"{params.conf}\" > {params.conf_fname}
        Rscript {SNAKE_DIR}/scripts/gisaidr-fetch_example.R {params.conf_fname} {params.basename}
        """
