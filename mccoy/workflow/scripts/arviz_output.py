import re
from pathlib import Path

import arviz as az
import matplotlib.pyplot as plt
import pandas as pd
import typer
import xarray as xr


def camel_to_title_case(column: str):
    """
    Transforms camel case to title case with space delimited.

    Regex from https://stackoverflow.com/a/9283563
    """
    return re.sub(r'((?<=[a-z])[A-Z]|(?<!\A)[A-Z](?=[a-z]))', r' \1', column).title()


def pandas_to_bootstrap(df, output: Path = None):
    """
    Adapted from https://stackoverflow.com/a/62153724
    """
    dict_data = [df.to_dict(), df.to_dict('index')]

    html = '<div class="table-responsive"><table class="table table-sm table-striped table-hover table-sm align-middle"><tr class="table-primary">'

    column_names = [df.index.name] + list(dict_data[0].keys())
    for key in column_names:
        html += f'<th class="header" scope="col">{key}</th>'

    html += '</tr>'

    for key in dict_data[1].keys():
        html += f'<tr><th class="index " scope="row">{key}</th>'
        for subkey in dict_data[1][key]:
            cell_text = dict_data[1][key][subkey] if not pd.isna(dict_data[1][key][subkey]) else "—"
            html += f'<td>{cell_text}</td>'

    html += '</tr></table></div>'
    if output:
        output.parent.mkdir(exist_ok=True, parents=True)
        output.write_text(html)

    return html


def arviz_output(
    trace_log: Path = typer.Argument(..., help="The path to the trace log from beast."),
    summary_html: Path = typer.Argument(...),
    posterior_svg: Path = typer.Argument(...),
    pairplot_svg: Path = typer.Argument(...),
    burnin: float = 0.1,
):
    df = pd.read_csv(trace_log, sep="\t", comment="#").rename(columns={'Sample': 'draw'})
    burnin_df = df.truncate(after=burnin * len(df))
    posterior_df = df.truncate(before=burnin * len(df))
    figsize = [14, 14]

    posterior_df["chain"] = 0
    posterior_df = posterior_df.set_index(["chain", "draw"])

    xdata = xr.Dataset.from_dataframe(posterior_df)
    dataset = az.InferenceData(posterior=xdata)
    az.plot_posterior(dataset, figsize=figsize, textsize=10)

    plt.savefig(posterior_svg)

    summary = az.summary(dataset)
    pandas_to_bootstrap(summary, summary_html)

    az.plot_pair(dataset, kind='kde', figsize=figsize, textsize=8)
    plt.savefig(pairplot_svg)


if __name__ == "__main__":
    typer.run(arviz_output)
