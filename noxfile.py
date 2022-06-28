import nox
from nox_poetry import session

nox.options.sessions = ["test"]


@session(python=["3.7", "3.8", "3.9", "3.10"])
def test(session):
    session.install("pytest")
    session.run("pytest")


@session
def style(session):
    session.run("pre-commit", "run", "--all-files", "--show-diff-on-failure", external=True)


@session
def docs(session):
    session.install("sphinx", "sphinx-rtd-theme", "myst-parser", "sphinx-copybutton")
    session.run("sphinx-build", "docs", "docs/_build/html")
