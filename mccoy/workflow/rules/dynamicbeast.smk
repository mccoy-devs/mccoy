rule dynamicbeast:
    input:
        template=RESOURCES_DIR/templates/"CoV_CE_fixed_clock_template.xml"
    output:
        RESOURCES_DIR/templates/ "dynamic_{template}.xml",
    conda:
        SNAKE_DIR / "envs/dynamicbeastfiles.yml"
    log:
        LOG_DIR / "dynamic_{id}.log",
    params:
        lambda wildcards: " ".join(config["dynamicbeastfiles"]["dynamicbeast"]),
    shell:

        """
        dynamicbeast {input.template} > {output}
        """
