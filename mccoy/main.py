import os
import shutil
import sys
from glob import glob
from itertools import chain
from pathlib import Path
from typing import List, Optional

import snakemake
import typer

app = typer.Typer()


def create_project(project_name, reference: Path, xml_template: Path, copy_workflow: bool = False):
    project_dir = Path(f'{project_name}')
    mccoy_dir = Path(__file__).parent.resolve()

    try:
        project_dir.mkdir(exist_ok=False)
    except FileExistsError as err:
        raise Exception("Project directory already exists!") from err

    shutil.copyfile(f"{mccoy_dir}/config/config.yaml", f"{project_name}/config.yaml")

    if copy_workflow:
        shutil.copytree(f"{mccoy_dir}/workflow", f"{project_name}/workflow")

    resources_dir = project_dir / "resources"
    shutil.copyfile(reference, resources_dir / "reference.fasta")
    shutil.copyfile(xml_template, resources_dir / "template.xml")

    shutil.copyfile(mccoy_dir / "tests.py", project_dir / "tests.py")
    (project_dir / 'runs').mkdir()


def get_last_run_id(project_path):
    runs = [int(run.split("_")[-1]) for run in glob(f"{project_path}/runs/*") if Path(run).is_dir()]
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
def callback(ctx: typer.Context):
    """
    \b
    The
      __  __       _____
     |  \/  |     / ____|
     | \  / | ___| |     ___  _   _
     | |\/| |/ __| |    / _ \| | | |
     | |  | | (__| |___| (_) | |_| |
     |_|  |_|\___|\_____\___/ \__, |
                               __/ |
                              |___/   CLI
    """


@app.command()
def create(
    project: Path = typer.Argument(..., file_okay=False, dir_okay=True),
    reference: Path = typer.Option(..., "--reference", "-r", exists=True, file_okay=True, dir_okay=False),
    template: Path = typer.Option(..., "--template", "-t", exists=True, file_okay=True, dir_okay=False),
    copy_workflow: bool = typer.Option(
        False, "--copy-workflow", "-c", help="Copy the workflow into the project for customisation."
    ),
):
    """
    Create a McCoy project
    """
    if project.exists():
        typer.echo(f"Project already exists: '{project}'")
        raise typer.Exit(1)
    typer.echo(f"Creating new project: {project}")
    create_project(project, reference, template, copy_workflow=copy_workflow)


def _print_snakemake_help(value: bool):
    if value:
        snakemake.main("-h")


@app.command(
    context_settings={"allow_extra_args": True, "ignore_unknown_options": True, "help_option_names": ["-h", "--help"]}
)
def run(
    ctx: typer.Context,
    project: Path = typer.Argument(..., exists=True, file_okay=False, dir_okay=True),
    data: List[Path] = typer.Option(..., exists=True, file_okay=True, dir_okay=False),
    inherit: Optional[Path] = typer.Option(None, exists=True, file_okay=False, dir_okay=True),
    inherit_last: Optional[bool] = False,
    cores: Optional[int] = typer.Option(1, "--cores", "-c", help="Number of cores to request for the workflow"),
    config: Optional[List[str]] = typer.Option(
        [], "--config", "-C", help="Set or overwrite values in the workflow config object (see Snakemake docs)"
    ),
    help_snakemake: Optional[bool] = typer.Option(
        False, help="Print the snakemake help", is_eager=True, callback=_print_snakemake_help
    ),
):
    """
    Run McCoy.

    All unrecognised arguments will be passed directly to snakemake. Rerun with `--help-snakemake` to see a list of
    all available snakemake arguments.
    """
    if str(project) == '.':
        project = Path(os.getcwd())
    run_id = create_run(project)
    project_id = project.name
    if inherit_last:
        last_run_id = run_id - 1
        inherit = f"{project}/runs/run_{last_run_id}"
    if inherit:
        inherit_data = glob(f"{inherit}/data/*-combined.fasta")
        data = inherit_data + data
        # copy state file
        try:
            inherit_state_file_path = glob(f"{inherit}/results/*.state")[0]
        except IndexError:
            raise ValueError("Could not find state file.")
        run_path = f"{project}/runs/run_{run_id}"
        os.mkdir(f"{run_path}/data/")
        shutil.copyfile(inherit_state_file_path, f"{run_path}/data/{project_id}-{run_id}-beast.xml.state")

    mccoy_config = {
        'id': f"{project_id}-{run_id}",
        "project_id": project_id,
        "project_path": project,
        "run_id": run_id,
        "run_name": f"run_{run_id}",
        "data": [str(d) for d in data],
        "inherit": inherit,
    }

    config_strs = chain((f"{k}={v}" for k, v in mccoy_config.items()), config)
    snakefile = f"{project}/workflow/Snakefile"
    args = [
        f"--snakefile={snakefile}",
        "--use-conda",
        f"--configfile={project}/config.yaml",
        f"--cores={cores}",
        *ctx.args,
        "--config",
        *config_strs,
    ]

    typer.echo(f"Running workflow: {run_id}")
    typer.secho(f"snakemake {' '.join(args)}", fg=typer.colors.BLACK)
    status = snakemake.main(args)

    sys.exit(0 if status else 1)
