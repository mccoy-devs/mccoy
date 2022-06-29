import pytest


@pytest.mark.skip(reason="The current test dataset leads to unstable results (even with same random seed).")
def test_tree(run_workflow):
    run_workflow("results/tree/expected-1.fasta.bionj").assert_expected()
