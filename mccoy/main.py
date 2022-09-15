import re
import shutil
import subprocess
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
    resources_dir.mkdir()
    shutil.copyfile(reference, resources_dir / "reference.fasta")
    shutil.copyfile(xml_template, resources_dir / "template.xml")

    shutil.copyfile(mccoy_dir / "tests.py", project_dir / "tests.py")
    (project_dir / 'runs').mkdir()


def get_last_run_id(project_path):
    runs = [int(run.split("_")[-1]) for run in glob(f"{project_path}/runs/*") if Path(run).is_dir()]
    if runs:
        return max(runs)
    return None


def create_run(project_path: Path, cont: bool = False):
    last_run_id = get_last_run_id(project_path)
    if last_run_id:
        run_id = last_run_id + 1 if not cont else last_run_id
    else:
        run_id = 1
    run_dir = project_path / f'runs/run_{run_id}'
    run_dir.mkdir(exist_ok=True)
    return run_id, run_dir


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
    """  # noqa: W605
    pass


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
    config: Optional[List[str]] = typer.Option(
        [], "--config", "-C", help="Set or overwrite values in the workflow config object (see Snakemake docs)"
    ),
    cont: Optional[bool] = typer.Option(False, "--continue", help="Continue previous run inplace"),
    conda_prefix: Optional[Path] = typer.Option(
        None,
        file_okay=False,
        dir_okay=True,
        help="Conda environment prefix. By default set to f\"{project}/.conda\"",
    ),
    hpc: bool = typer.Option(False, help="Run on an HPC cluster (with the SLURM scheduler)?"),
    help_snakemake: Optional[bool] = typer.Option(
        False, help="Print the snakemake help", is_eager=True, callback=_print_snakemake_help
    ),
    verbose: Optional[bool] = typer.Option(False, "--verbose"),
):
    """
    Run McCoy.

    All unrecognised arguments will be passed directly to snakemake. Rerun with `--help-snakemake` to see a list of
    all available snakemake arguments.
    """
    run_id, run_dir = create_run(project, cont=cont)
    project_id = project.resolve().name
    if inherit_last:
        last_run_id = run_id - 1
        inherit = project / f"runs/run_{last_run_id}"
    if inherit:
        inherit_data = list(inherit.glob("data/combined/*.fasta"))
        data = inherit_data + data
        # copy state file
        try:
            inherit_state_file_path = list((inherit / "results/beast").glob("*.state"))[0]
        except IndexError:
            raise ValueError("Could not find state file.")
        data_dir = run_dir / "data"
        data_dir.mkdir(exist_ok=True)
        shutil.copyfile(inherit_state_file_path, data_dir / f"{project_id}-{run_id}-beast.xml.state")

    mccoy_config = {
        'id': f"{project_id}-{run_id}",
        "project_id": project_id,
        "project_path": project.resolve(),
        "run_id": run_id,
        "run_name": f"run_{run_id}",
        "data": [str(d.resolve()) for d in data],
        "inherit": inherit or False,
    }

    config_strs = chain((f"{k}={v}" for k, v in mccoy_config.items()), config)
    workflow_dir = project / "workflow"
    if workflow_dir.exists():
        snakefile = workflow_dir / "Snakefile"
    else:
        snakefile = Path(__file__).parent / "workflow/Snakefile"

    conda_prefix_dir = f"{project.resolve() / '.conda'}" if not conda_prefix else conda_prefix

    args = [
        f"--snakefile={snakefile}",
        f"--directory={run_dir}",
        f"--configfile={project}/config.yaml",
        f"--conda-prefix={conda_prefix_dir}",
    ]

    # Set up conda frontend
    mamba_found = True
    try:
        subprocess.run(["mamba", "--version"], capture_output=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        mamba_found = False
    if not mamba_found:
        args.append("--conda-frontend=conda")

    if all(('profile' not in re.split(r' |=', arg)[0] for arg in ctx.args)):
        if hpc:
            args.append(f"--profile={Path(__file__).parent.resolve()/'profiles/slurm'}")
        else:
            args.append(f"--profile={Path(__file__).parent.resolve()/'profiles/local'}")

    if verbose:
        args.insert(0, "--verbose")
        typer.secho(f"Running workflow: {run_id}", fg=typer.colors.MAGENTA)
        typer.secho(f"snakemake {' '.join(args)}", fg=typer.colors.MAGENTA)

    args.extend([*ctx.args, "--config", *config_strs])

    status = snakemake.main(args)

    sys.exit(0 if status else 1)
