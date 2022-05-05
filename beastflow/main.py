import os
import shutil
from glob import glob
from pathlib import Path
from typing import List, Optional

import snakemake
import typer

app = typer.Typer()


def create_project(project_name, reference: Path, xml_template: Path):
    os.mkdir(f'{project_name}')
    beastflow_dir = Path(__file__).parent.resolve()
    shutil.copyfile(f"{beastflow_dir}/config/config.yaml", f"{project_name}/config.yaml")
    shutil.copytree(f"{beastflow_dir}/workflow", f"{project_name}/workflow")
    os.mkdir(f'{project_name}/resources')
    shutil.copyfile(reference, f"{project_name}/resources/reference.fasta")
    shutil.copyfile(xml_template, f"{project_name}/resources/template.xml")
    os.mkdir(f'{project_name}/runs')

def get_last_run_id(project_path):
    runs = [int(run.split("_")[1]) for run in glob(f"{project_path}/runs/*") if Path(run).is_dir()]
    if runs:
        return max(runs)
    return None

def create_run(project_path: Path):
    last_run_id = get_last_run_id(project_path)
    if last_run_id:
        run_id = last_run_id + 1
    else:
        run_id = 1
    run_dir = f'{project_path}/runs/run_{run_id}'
    os.mkdir(run_dir)
    return run_id


@app.callback()
def callback():
    """
    Beastflow CLI
    """

@app.command()
def create(
    project: Path = typer.Argument(..., file_okay=False, dir_okay=True),
    reference: Path = typer.Option(..., exists=True, file_okay=True, dir_okay=False),
    template: Path = typer.Option(..., exists=True, file_okay=True, dir_okay=False),
):
    """
    Create a beastflow project
    """
    if project.exists():
        typer.echo(f"Project already exists: '{project}'")
        raise typer.Exit(1)
    typer.echo(f"Creating new project: {project}")
    create_project(project, reference, template)


@app.command()
def run(
    project: Path = typer.Argument(..., exists=True, file_okay=False, dir_okay=True),
    data: List[Path] = typer.Option(..., exists=True, file_okay=True, dir_okay=False),
    inherit: Optional[Path] = typer.Option(None, exists=True, file_okay=False, dir_okay=True),
    inherit_last: Optional[bool] = typer.Option(False),
):
    """
    Run beastflow
    """
    project_id = project.name
    run_id = create_run(project)
    snakefile = f"{project}/workflow/Snakefile"
    if inherit_last:
        last_run_id = run_id - 1
        inherit_data = glob(f"{project}/runs/run_{last_run_id}/data/*-combined.fasta")
        data.append(inherit_data)
    elif inherit:
        inherit_data = glob(f"{inherit}/data/*-combined.fasta")
        data.append(inherit_data)
    config = {
        'id': f"{project_id}-{run_id}",
        "project_id": project_id,
        "project_path": project,
        "run_id": run_id,
        "run_name": f"run_{run_id}",
        "data": data,
    }
    typer.echo(f"Running workflow: {run_id}")
    status = snakemake.snakemake(
        snakefile=snakefile, use_conda=True, config=config, configfiles=[f"{project}/config.yaml"]
    )
