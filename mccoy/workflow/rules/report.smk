from pathlib import Path
import jinja2
import typer
from jinja2.utils import markupsafe

rule report:
    input:
        phytest=rules.phytest.output,
        iqtree_report="results/tree/{id}.fasta.iqtree",
        iqtree_log="results/tree/{id}.fasta.log",
        mltree_svg=rules.render_mltree.output.svg,
        consensus_mltree_svg=rules.render_consensus_mltree.output.svg,
        mcmc_output=expand(rules.beast.output, id=config['id']),
        traces_dir=rules.plot_traces.output[0],
        alignment_summary=rules.alignment_stats.output.summary,
        gc_content=rules.alignment_stats.output.gc_content,
        relative_composition_variability=rules.alignment_stats.output.relative_composition_variability,
        pairwise_identity=rules.alignment_stats.output.pairwise_identity,
        pairwise_identity_histogram=rules.pairwise_identity_histogram.output.html,
        arviz_summary=rules.arviz.output.summary_html,
        arviz_posterior_svg=rules.arviz.output.posterior_svg,
        arviz_pairplot_svg=rules.arviz.output.pairplot_svg,
        max_clade_credibility_tree_svg=rules.max_clade_credibility_tree_render.output.svg,
    output:
        html="{id}-report.html"
    run:
        report_dir = SNAKE_DIR/"report"
        loader = jinja2.FileSystemLoader(report_dir)
        env = jinja2.Environment(
            loader=loader,
            autoescape=jinja2.select_autoescape()
        )
        def include_file(name):
            print('include', name)
            if name:
                return markupsafe.Markup(Path(str(name)).read_text())
            return ""

        def include_raw(name):
            print('include raw', name)
            if name:
                file = report_dir/name
                return markupsafe.Markup(file.read_text())
            return ""

        env.globals['include_file'] = include_file
        env.globals['include_raw'] = include_raw

        output_path = Path(output.html).resolve()

        template = env.get_template("report-template.html")
        try:
            result = template.render(
                input=input,
                traces=Path(input.traces_dir).glob("*.svg"),
            )
        except Exception as err:
            print(f"could not render template: {err}")


        with open(output_path, 'w') as f:
            print(f"Writing result to {output_path}")
            f.write(result)        