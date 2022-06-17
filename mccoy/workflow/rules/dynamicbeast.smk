rule dynamicbeast:
    input:
        template=RESOURCES_DIR / "template.xml",
        phytest_report="results/{id}-phytest.html",
    output:
        "results/beast/{id}-dynamic_beast.xml",
    log:
        "logs/{id}-dynamic_beast.log",
    conda:
        "envs/dynamicbeast.yml"
    shell:
        """
        dynamic-beast {input.template} > {output}
        """
