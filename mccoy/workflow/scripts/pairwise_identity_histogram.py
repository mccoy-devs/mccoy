import re
from pathlib import Path

import numpy as np
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import typer
from plotly.subplots import make_subplots


def format_fig(fig):
    fig.update_layout(
        width=1200,
        height=550,
        plot_bgcolor="white",
        title_font_color="black",
        font=dict(
            family="Linux Libertine Display O",
            size=18,
            color="black",
        ),
    )
    gridcolor = "#dddddd"
    fig.update_xaxes(gridcolor=gridcolor)
    fig.update_yaxes(gridcolor=gridcolor)

    fig.update_xaxes(showline=True, linewidth=1, linecolor='black', mirror=True, ticks='outside')
    fig.update_yaxes(showline=True, linewidth=1, linecolor='black', mirror=True, ticks='outside')
    fig.update_xaxes(zeroline=True, zerolinewidth=1, zerolinecolor=gridcolor)
    fig.update_yaxes(zeroline=True, zerolinewidth=1, zerolinecolor=gridcolor)


def pairwise_identity_histogram(
    pairwise_identity_verbose: Path = typer.Argument(..., help="The path to the trace log from beast."),
    svg: Path = typer.Argument(..., help="A path to the output SVG file."),
    html: Path = typer.Argument(..., help="A path to the output HTML file."),
):
    values = []
    for line in pairwise_identity_verbose.read_text().split("\n"):
        try:
            if line:
                value = float(line.split("\t")[1])
                values.append(value)
        except:
            print(f"cannot interpret line: {line}")

    fig = px.histogram(values, labels={'value': "Pairwise identity"})
    format_fig(fig)
    fig.update_layout(
        showlegend=False,
        yaxis_title="Number of pairs",
        xaxis_title="Pairwise identity",
        xaxis_tickformat='.%',
    )
    fig.write_image(svg)
    fig.write_html(html)


if __name__ == "__main__":
    typer.run(pairwise_identity_histogram)
