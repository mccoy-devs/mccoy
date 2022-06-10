rule dynamicbeast:
    input:
        template=RESOURCES_DIR / "template.xml",
    output:
        RESULTS_DIR / "dynamic_beast_input.xml",
    conda:
        ENVS_DIR / "dynamicbeast.yml"
    log:
        LOG_DIR / "dynamic_beast.log",
    shell:
        """
        dynamic-beast {input.template} > {output}
        """
