import platform
import shutil
from pathlib import Path

import nox
from nox_poetry import session

nox.options.sessions = ["test"]


@session(python=["3.7", "3.8", "3.9", "3.10"])
def test(session):
    session.env["IQTREE_SEED"] = "28379373"
    session.install("pytest", "typer", "DendroPy>=4.5.2", ".")
    session.run("pytest", "-s", "-x")


@session
def regen_expected(session):
    if platform.system() == "Darwin" and platform.processor() == "arm":
        session.env["CONDA_SUBDIR"] = "osx-64"

    session.install(".")
    session.env["IQTREE_SEED"] = "28379373"
    shutil.rmtree("tests/expected", ignore_errors=True)
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
    session.run(
        "mccoy",
        "run",
        "tests/expected",
        "--data",
        "tests/data2.fasta",
        "--inherit-last",
        "-c",
        "4",
    )


@session
def style(session):
    session.run("pre-commit", "run", "--all-files", "--show-diff-on-failure", external=True)


@session
def docs(session):
    session.install(
        "sphinx",
        "sphinx-immaterial",
        "sphinxcontrib-mermaid",
        "snakedoc@git+https://github.com/smutch/snakedoc.git@main",
        ".",
    )
    with session.chdir("docs"):
        session.run("sphinx-build", ".", "./_build/html")


@session
def docs_github(session):
    session.install(
        "sphinx",
        "sphinx-immaterial",
        "sphinxcontrib-mermaid",
        "snakedoc@git+https://github.com/smutch/snakedoc.git@main",
        ".",
    )
    with session.chdir("docs"):
        gh_pages = Path("gh-pages")
        gh_pages.mkdir()
        (gh_pages / ".nojekll").touch()
        session.run("sphinx-build", "-b", "html", ".", "gh-pages")
