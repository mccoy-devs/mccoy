import shutil
from itertools import chain
from pathlib import Path
from typing import List, Optional

import nox
from nox_poetry import session

nox.options.sessions = ["test"]


@session(python=["3.7", "3.8", "3.9", "3.10"])
def test(session):
    session.env["IQTREE_SEED"] = "28379373"
    session.install("pytest", "typer", ".")
    session.run("pytest", "-s")


@session
def regen_expected(session):
    session.env["IQTREE_SEED"] = "28379373"
    shutil.rmtree("tests/expected")
    session.run(
        "mccoy",
        "create",
        "tests/expected",
        "--reference",
        "resources/reference.fasta",
        "--template",
        "resources/templates/CoV_CE_fixed_clock_template.xml",
    )
    session.run("mccoy", "run", "tests/expected", "--data", "tests/data.fasta", "-c", "4")


@session
def style(session):
    session.run("pre-commit", "run", "--all-files", "--show-diff-on-failure", external=True)


@session
def docs(session):
    session.install("sphinx", "sphinx-rtd-theme", "myst-parser", "sphinx-copybutton", ".")
    session.run("sphinx-build", "docs", "docs/_build/html")


@session
def docs_github(session):
    session.install("sphinx", "sphinx-rtd-theme", "myst-parser", "sphinx-copybutton", ".")
    gh_pages = Path("gh-pages")
    gh_pages.mkdir()
    (gh_pages / ".nojekll").touch()
    session.run("sphinx-build", "-b", "html", "docs", "gh-pages")


_envs_dir = Path("mccoy/workflow/envs")
_env_files = list(str(p) for p in chain(_envs_dir.glob(r"*.yml"), _envs_dir.glob(r"*.yaml")))


@session
@nox.parametrize('env', _env_files)
def lock_conda_envs(session, env):
    session.install("conda-lock[pip_support]")
    name = Path(env).stem
    loc = Path(env).parents[0]
    session.run(
        "conda-lock",
        "--mamba",
        "-p",
        "linux-64",
        "-p",
        "osx-64",
        "-f",
        env,
        "-k",
        "explicit",
        "--filename-template",
        str(loc / f"{name}.{{platform}}.pin.txt"),
    )
