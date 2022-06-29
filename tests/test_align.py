def test_align(run_workflow):
    run_workflow("results/aligned/expected-1.fasta").assert_expected()
