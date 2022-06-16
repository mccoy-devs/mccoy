rule dynamicbeast:
    input:
        template=RESOURCES_DIR / "template.xml",
        phytest_report=RESULTS_DIR / "{id}-phytest.html",
    output:
        RESULTS_DIR / "{id}-dynamic_beast.xml",
    conda:
        ENVS_DIR / "dynamicbeast.yml"
    log:
        LOG_DIR / "{id}-dynamic_beast.log",
    shell:
        """
        dynamic-beast {input.template} > {output}
        """
