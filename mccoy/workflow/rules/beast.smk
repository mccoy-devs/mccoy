rule onlinebeast:
    input:
        xml=rules.dynamicbeast.output,
        alignment=rules.align.output,
    output:
        "results/beast/{id}-online_beast.xml",
    log:
        "logs/{id}-onlinebeast.log",
    conda:
        "../envs/beast.yml"
    shell:
        """
        online-beast {input.xml} {input.alignment} --state-file data/{wildcards.id}-beast.xml.state --output {output} --template --no-date-trait
        """


rule beast:
    input:
        alignment=rules.align.output,
        template=rules.onlinebeast.output if config['inherit'] else rules.dynamicbeast.output,
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
        beast=lambda wildcards: " ".join(config["beast"]["beast"]),
    threads: config["beast"]["threads"]
    resources:
        **config["beast"].get("resources", {}),
    shell:
        """
        beast -D 'alignment={input.alignment},tracelog={output.tracelog},treelog={output.treelog},mcmc.threads={threads},{params.dynamic}' {params.beast} -statefile {output.statefile} {input.template} 1>&2 2> {log}
        """
