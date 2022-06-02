rule phylogenetics:
    input:
        original=RESOURCES_DIR / "{id}-aligned.fasta",
        template=RESOURCES_DIR / templates / "CoV_CE_fixed_clock_template.xml",
    output:
        RESOURCES_DIR / "{id}.trees",
        RESOURCES_DIR / "{id}.log",
    conda:
        SNAKE_DIR / "envs/beast.yml"
    log:
        LOG_DIR / "{id}.log",
    params:
        lambda wildcards: " ".join(config["beast"]["phylogenetics"]),
    threads: 4
    resources:
        time="00:10:00",
        mem="8G",
        cpus=4,
    shell:
        """
        beast {input.template} > {output}
        """
