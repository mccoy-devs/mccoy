import os
import shutil
import subprocess as sp
import sys
from pathlib import Path, PurePosixPath
from tempfile import TemporaryDirectory

sys.path.insert(0, os.path.dirname(__file__))

import common


def test_tree():

    with TemporaryDirectory() as tmpdir:
        workdir = Path(tmpdir) / "workdir"
        data_path = PurePosixPath("../../../tree/data")
        expected_path = PurePosixPath("../../../tree/expected")

        # Copy data to the temporary workdir.
        shutil.copytree(data_path, workdir)

        # dbg
        print(
            "results/tree/project-1.fasta.treefile results/tree/project-1.fasta.bionj results/tree/project-1.fasta.ckp.gz results/tree/project-1.fasta.contree results/tree/project-1.fasta.iqtree results/tree/project-1.fasta.log results/tree/project-1.fasta.mldist results/tree/project-1.fasta.splits.nex",
            file=sys.stderr,
        )

        # Run the test job.
        sp.check_output(
            [
                "python",
                "-m",
                "snakemake",
                "results/tree/project-1.fasta.treefile results/tree/project-1.fasta.bionj results/tree/project-1.fasta.ckp.gz results/tree/project-1.fasta.contree results/tree/project-1.fasta.iqtree results/tree/project-1.fasta.log results/tree/project-1.fasta.mldist results/tree/project-1.fasta.splits.nex",
                "-f",
                "-j1",
                "--keep-target-files",
                "--configfile",
                "/Users/smutch/work/mdap/collabs/2022/duchene/duchene-mdap-2022/tests/project/config.yaml",
                "--use-conda",
                "--directory",
                workdir,
            ]
        )

        # Check the output byte by byte using cmp.
        # To modify this behavior, you can inherit from common.OutputChecker in here
        # and overwrite the method `compare_files(generated_file, expected_file),
        # also see common.py.
        common.OutputChecker(data_path, expected_path, workdir).check()
