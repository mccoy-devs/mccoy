import nox

nox.options.sessions = ["test"]


@nox.session(python=["3.7", "3.8", "3.9", "3.10"])
def test(session):
    session.run("poetry", "install", "-v", external=True)
    session.run("poetry", "run", "pytest", external=True)


@nox.session
def style(session):
    session.run("pre-commit", "run", "--all-files", "--show-diff-on-failure", external=True)


@nox.session
def docs(session):
    session.run("poetry", "run", "sphinx-build", "docs", "docs/_build/html", external=True)
