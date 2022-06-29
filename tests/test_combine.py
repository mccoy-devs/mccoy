def test_combine(run_workflow):
    run_workflow("data/combined/expected-1.fasta").assert_expected()
