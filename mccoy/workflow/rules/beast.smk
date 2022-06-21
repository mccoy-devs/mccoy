rule beast:
    input:
        alignment=rules.align.output,
        template=rules.dynamicbeast.output,
    output:
        treelog=RESULTS_DIR / "beast/{id}-tree.log",
        tracelog=RESULTS_DIR / "beast/{id}-trace.log",
        statefile=RESULTS_DIR / "beast/{id}-beast.xml.state",
    conda:
        ENVS_DIR / "beast.yml"
    log:
        LOG_DIR / "{id}_beast.log",
    params:
        beast=lambda wildcards: ",".join(config["beast"]),
    shell:
        """
        beast -D 'alignment={input.alignment},tracelog={output.tracelog},treelog={output.treelog},{params.beast}' -statefile {output.statefile} {input.template} 2>&1 1> {log}
        """
