from xml.dom.minidom import Document, Element, parse


def test_beast(run_workflow):
    """
    We are running MCMC in beast, which is an inherintly stochastic process, so we can't just directly compare
    the output files with the expected result.
    """

    workflow = run_workflow(
        [
            "results/beast/expected-1-tree.log",
            "results/beast/expected-1-trace.log",
            "results/beast/expected-1-beast.xml.state",
        ]
    )

    for target in workflow.targets:
        assert (workflow.work_dir / target).exists()

    # The first `n_lines` of the tree file should match...
    n_lines = 142
    expected = (workflow.expected_dir / workflow.targets[0]).read_text().splitlines()[:n_lines]
    result = (workflow.work_dir / workflow.targets[0]).read_text().splitlines()[:n_lines]
    assert expected == result, f"First {n_lines} of {str(workflow.targets[0])} does not match expected"

    # Ensure we completed the requested number of samples
    with (workflow.work_dir / workflow.targets[2]).open("r") as fp:
        doc: Document = parse(fp)
    element: Element = doc.getElementsByTagName("itsabeastystatewerein")[0]
    assert element.getAttribute("sample") == "10000"
