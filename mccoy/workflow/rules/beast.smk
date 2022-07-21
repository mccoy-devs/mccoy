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
        dynamic=lambda wildcards: ",".join(config["beast"]["dynamic"]),
        cmdline=lambda wildcards: " ".join(config["beast"]["cmdline"]),
    resources:
        **config["beast"].get("resources", {}),
    shell:
        """
        beast -D 'alignment={input.alignment},tracelog={output.tracelog},treelog={output.treelog},{params.dyn_vars}' {params.beast_flags} -statefile {output.statefile} {input.template} 1>&2 2> {log}
        """
