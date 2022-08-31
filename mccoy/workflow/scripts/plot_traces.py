from pathlib import Path
import pandas as pd
import typer
import re
import plotly.express as px

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

def camel_to_title_case(column:str):
    """ 
    Transforms camel case to title case with space delimited.
    
    Regex from https://stackoverflow.com/a/9283563 
    """
    return re.sub(r'((?<=[a-z])[A-Z]|(?<!\A)[A-Z](?=[a-z]))', r' \1', column).title()


def plot_traces(
    trace_log: Path = typer.Argument(..., help="The path to the trace log from beast."),
    output: Path = typer.Argument(..., help="A path to the output directory."),
    burnin:float = 0.1
):
    output.mkdir(exist_ok=True, parents=True)

    df = pd.read_csv(trace_log, sep="\t", comment="#")
    burnin_df = df.truncate(after=burnin*len(df))
    posterior_df = df.truncate(before=burnin*len(df))
    for variable in df.columns[1:]:
        print(variable)
        variable_title = camel_to_title_case(variable)
        print(f"Plotting {variable_title}")
        fig = px.scatter(posterior_df, x="Sample", y=variable, marginal_y="histogram")
        format_fig(fig)
        fig.data[0].update(mode='markers+lines')
        fig.update_layout(
            yaxis_title=variable_title,
        )
        fig.write_image(output/f"{variable}.svg")



if __name__ == "__main__":
    typer.run(plot_traces)
