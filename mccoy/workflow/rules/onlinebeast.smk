rule onlinebeast:
    input:
        xml=rules.dynamicbeast.output,
        alignment=rules.align.output,
        statefile=DATA_DIR / "{id}-beast.xml.state",
    output:
        treelog=RESULTS_DIR / "{id}-tree.log",
        tracelog=RESULTS_DIR / "{id}-trace.log",
        statefile=RESULTS_DIR / "{id}-beast.xml.state",
    conda:
        ENVS_DIR / "beast.yml"
    log:
        LOG_DIR / "{id}-beast.log",
    params:
        beast=lambda wildcards: ",".join(config["beast"]),
        statefile=RESULTS_DIR / f"{config['id']}-beast.xml",
    shell:
        """
        online-beast {input.xml} {input.alignment} --state-file {input.statefile} --output {params.statefile} --template --no-date-trait
        beast -D 'alignment={input.alignment},tracelog={output.tracelog},treelog={output.treelog},{params.beast}' -resume -statefile {output.statefile} {input.xml} 2>&1 1> {log}
        """
