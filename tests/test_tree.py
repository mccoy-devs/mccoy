import dendropy


def test_tree(run_workflow):
    treefile = "results/tree/expected-1.fasta.treefile"
    workflow = run_workflow(treefile)

    tns = dendropy.TaxonNamespace()
    tree1 = dendropy.Tree.get_from_path(workflow.work_dir / treefile, "newick", taxon_namespace=tns)
    tree2 = dendropy.Tree.get_from_path(workflow.expected_dir / treefile, "newick", taxon_namespace=tns)
    tree1.encode_bipartitions()
    tree2.encode_bipartitions()

    distance = dendropy.calculate.treecompare.euclidean_distance(tree1, tree2)
    assert distance <= 1
