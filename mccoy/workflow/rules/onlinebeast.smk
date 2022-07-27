rule onlinebeast:
    input:
        xml=rules.dynamicbeast.output,
        alignment=rules.align.output,
        statefile="data/{id}-beast.xml.state",
    output:
        treelog="results/beast/{id}-tree.log",
        tracelog="results/beast/{id}-trace.log",
        statefile="results/beast/{id}-beast.xml.state",
        online_statefile="results/beast/{id}-beast.xml",
    log:
        "logs/{id}-beast.log",
    conda:
        "../envs/beast.yml"
    params:
        dynamic=lambda wildcards: ",".join(config["beast"]["dynamic"]),
        beast=lambda wildcards: " ".join(config["beast"]["beast"]),
    shell:
        """
        online-beast {input.xml} {input.alignment} --state-file {input.statefile} --output {output.online_statefile} --template --no-date-trait
        beast -D 'alignment={input.alignment},tracelog={output.tracelog},treelog={output.treelog},mcmc.threads={threads},{params.dynamic}' {params.beast} -statefile {output.statefile} {input.xml} 1>&2 2> {log}
        """
