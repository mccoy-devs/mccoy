def test_dynamicbeast(run_workflow):
    run_workflow("results/beast/expected-1-dynamic_beast.xml").assert_expected()
