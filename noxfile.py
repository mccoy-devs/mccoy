import shutil

import nox
from nox_poetry import session

nox.options.sessions = ["test"]


@session(python=["3.7", "3.8", "3.9", "3.10"])
def test(session):
    session.env["IQTREE_SEED"] = "28379373"
    session.install("pytest", "typer")
    session.run("pytest")


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
    session.install("sphinx", "sphinx-rtd-theme", "myst-parser", "sphinx-copybutton")
    session.run("sphinx-build", "docs", "docs/_build/html")
