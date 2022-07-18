rule beast:
    input:
        alignment=rules.align.output,
        template=rules.dynamicbeast.output,
    output:
        treelog="results/beast/{id}-tree.log",
        tracelog="results/beast/{id}-trace.log",
        statefile="results/beast/{id}-beast.xml.state",
    log:
        "logs/{id}_beast.log",
    conda:
        "../envs/beast.yml"
    params:
        dyn_vars=lambda wildcards: ",".join(config["beast"]["dynamic-variables"]),
        beast_flags=lambda wildcards: " ".join(config["beast"]["beast"]),
    resources:
        **config["beast"].get("resources", {}),
    shell:
        """
        beast -D 'alignment={input.alignment},tracelog={output.tracelog},treelog={output.treelog},{params.dyn_vars}' {params.beast_flags} -statefile {output.statefile} {input.template} 2>&1 1> {log}
        """
