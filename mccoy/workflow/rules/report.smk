from pathlib import Path
import jinja2
import typer


rule report:
    input:
        phytest=rules.phytest.output,
        render_tree_svg=rules.render_tree.output.svg,
        mcmc_output=expand(rules.beast.output, id=config['id']),
        traces_dir=rules.plot_traces.output[0],
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
                return Path(str(name)).read_text()
            return ""

        env.globals['include_file'] = include_file
        output_path = Path(output.html).resolve()

        template = env.get_template("report-template.html")
        result = template.render(
            input=input,
            traces=Path(input.traces_dir).glob("*.html"),
        )

        with open(output_path, 'w') as f:
            print(f"Writing result to {output_path}")
            f.write(result)        