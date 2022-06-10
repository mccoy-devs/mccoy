rule beast:
    input:
        alignment=rules.align.output,
        template=rules.dynamicbeast.output,
    output:
        treelog="results/{id}-treelog.txt",
        tracelog="results/{id}-tracelog.txt",
    conda:
        ENVS_DIR / "beast.yml"
    log:
        LOG_DIR / "{id}_beast.log",
    params:
        lambda wildcards: ",".join(config["beast"]),
    shell:
        """
        beast -D 'alignment={input.alignment},tracelog={output.tracelog},treelog={output.treelog},{params}' {input.template}
        """
