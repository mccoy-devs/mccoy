rule beast:
    input:
        alignment=rules.align.output,
        template= rules.dynamicbeast.output,
    output:
        "results/{id}.trees",
        "results/{id}.log",
    conda:
        ENVS_DIR / "beast.yml"
    log:
        LOG_DIR / "{id}_beast.log",
    params:
        lambda wildcards: ",".join(config["beast"]),
    shell:
        """
        beast -D 'alignment={input.alignment},{params}' {input.template}
        """
