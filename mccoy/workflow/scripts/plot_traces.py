from pathlib import Path
import pandas as pd
import typer
import re
import plotly.express as px


def camel_to_title_case(column:str):
    """ 
    Transforms camel case to title case with space delimited.
    
    Regex from https://stackoverflow.com/a/9283563 
    """
    return re.sub(r'((?<=[a-z])[A-Z]|(?<!\A)[A-Z](?=[a-z]))', r' \1', column).title()


def plot_traces(
    trace_log: Path = typer.Argument(..., help="The path to the trace log from beast."),
    output: Path = typer.Argument(..., help="A path to the output directory."),
):
    output.mkdir(exist_ok=True, parents=True)

    df = pd.read_csv(trace_log, sep="\t", comment="#")
    for variable in df.columns[1:]:
        print(variable)
        variable_title = camel_to_title_case(variable)
        print(f"Plotting {variable_title}")
        fig = px.scatter(df, x="Sample", y=variable, marginal_y="histogram")
        fig.data[0].update(mode='markers+lines')
        fig.update_layout(
            yaxis_title=variable_title,
            xaxis_rangeslider=dict(
                visible=True
            ),
        )
        fig.write_html(output/f"{variable}.html")



if __name__ == "__main__":
    typer.run(plot_traces)
