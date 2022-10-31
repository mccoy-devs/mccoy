import re
from typing import AnyStr


def _strip_idents(text: AnyStr) -> AnyStr:
    """
    Strip out any randomly generated IDs.

    Plotly adds a heap of these to its output which will cause comparisons with the expected output to always fail.

    :param text AnyStr: Text to strip
    :rtype AnyStr: The same input text with any unique hashes or IDs stripped
    """
    return re.sub(
        r"(id=\"\S+\"|\"\w{8}-\w{4}-\w{4}-\w{4}-\w{12}\"|url\(#\S+\)|trace\w{6}|<dc:date>.*</dc:date>|href=\"#\w{11}\")",
        r"",
        text,
    )


# alignment module {{{


def test_alignment_stats(run_workflow):
    run_workflow(
        [
            "results/aligned/expected-1.summary.txt",
            "results/aligned/expected-1.gc_content.txt",
            "results/aligned/expected-1.relative_composition_variability.txt",
            "results/aligned/expected-1.pairwise_identity.txt",
            "results/aligned/expected-1.pairwise_identity_verbose.txt",
        ]
    ).assert_expected()


def test_pairwise_identity_histogram(run_workflow):
    workflow = run_workflow(
        [
            "results/aligned/expected-1.pairwise_identity_verbose.svg",
            "results/aligned/expected-1.pairwise_identity_verbose.html",
        ]
    )

    for target in workflow.targets:
        expected = _strip_idents((workflow.expected_dir / target).read_text())
        result = _strip_idents((workflow.work_dir / target).read_text())
        assert expected == result


# }}}

# phytest {{{


def test_phytest(run_workflow):
    run_workflow("results/expected-1-phytest.html").assert_expected()


# }}}

# tree module {{{


def test_render_mltree(run_workflow):
    workflow = run_workflow(
        [
            "results/tree/expected-1-mltree.svg",
            "results/tree/expected-1-mltree.html",
        ]
    )

    for target in workflow.targets:
        expected = _strip_idents((workflow.expected_dir / target).read_text())
        result = _strip_idents((workflow.work_dir / target).read_text())
        assert expected == result


def test_render_consensus_mltree(run_workflow):
    workflow = run_workflow(
        [
            "results/tree/expected-1-mltree-consensus.svg",
            "results/tree/expected-1-mltree-consensus.html",
        ]
    )

    for target in workflow.targets:
        expected = _strip_idents((workflow.expected_dir / target).read_text())
        result = _strip_idents((workflow.work_dir / target).read_text())
        assert expected == result


# }}}


# beast module {{{


def test_plot_traces(run_workflow):
    workflow = run_workflow("results/traces/")

    for expected_path in (workflow.expected_dir / workflow.targets[0]).iterdir():
        expected = _strip_idents(expected_path.read_text())
        result = _strip_idents((workflow.work_dir.joinpath(*expected_path.parts[-3:])).read_text())
        assert expected == result


def test_arviz(run_workflow):
    workflow = run_workflow(
        [
            "results/beast/expected-1-summary.html",
            "results/beast/expected-1-posterior.svg",
            "results/beast/expected-1-pairplot.svg",
        ]
    )

    for target in workflow.targets:
        expected = _strip_idents((workflow.expected_dir / target).read_text())
        result = _strip_idents((workflow.work_dir / target).read_text())
        assert expected == result


def test_max_clade_credibility_tree(run_workflow):
    run_workflow("results/beast/expected-1-maxcladecredibility.treefile").assert_expected()


def test_max_clade_credibility_tree_newick(run_workflow):
    run_workflow("results/beast/expected-1-maxcladecredibility.nwk").assert_expected()


def test_max_clade_credibility_tree_render(run_workflow):
    workflow = run_workflow(
        [
            "results/beast/expected-1-maxcladecredibility.svg",
            "results/beast/expected-1-maxcladecredibility.html",
        ]
    )

    for target in workflow.targets:
        expected = _strip_idents((workflow.expected_dir / target).read_text())
        result = _strip_idents((workflow.work_dir / target).read_text())
        assert expected == result


# }}}


def test_reporter(run_workflow):
    workflow = run_workflow("expected-1-report.html")

    for target in workflow.targets:
        expected = _strip_idents((workflow.expected_dir / target).read_text())
        expected = re.sub(str(workflow.expected_dir), "", expected)
        result = _strip_idents((workflow.work_dir / target).read_text())
        result = re.sub(str(workflow.work_dir), "", expected)
        assert expected == result
