from pathlib import Path

import typer
from jinja2 import Environment, FileSystemLoader, select_autoescape


def report(
    output: Path = typer.Option(..., help="The path to the phytest report."),
    phytest: Path = typer.Option(..., help="The path to the phytest report."),
):
    report_dir = Path(__file__).parent.parent / "report"
    env = Environment(loader=FileSystemLoader(report_dir), autoescape=select_autoescape())
    template = env.get_template("report-template.html")
    result = template.render(phytest=phytest)
    with open(output, 'w') as f:
        print(f"Writing result to {output}")
        f.write(result)


if __name__ == "__main__":
    typer.run(report)
