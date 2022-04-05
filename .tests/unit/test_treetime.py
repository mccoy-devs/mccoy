import os
import shutil
import subprocess as sp
import sys
from pathlib import Path, PurePosixPath
from tempfile import TemporaryDirectory

sys.path.insert(0, os.path.dirname(__file__))

import common


def test_treetime():
    # import pdb; pdb.set_trace()

    with TemporaryDirectory() as tmpdir:
        workdir = Path(tmpdir) / "workdir"
        data_path = PurePosixPath(".tests/unit/treetime/data")
        expected_path = PurePosixPath(".tests/unit/treetime/expected")

        # Copy data to the temporary workdir.
        shutil.copytree(data_path, workdir)

        # dbg
        print(
            "results/test-treetime/rerooted.newick results/test-treetime/rtt.csv results/test-treetime/root_to_tip_regression.pdf",
            file=sys.stderr,
        )

        # Run the test job.
        sp.check_output(
            [
                "python",
                "-m",
                "snakemake",
                "results/test-treetime/rtt.csv",
                "-f",
                "-j1",
                "--keep-target-files",
                "--use-conda",
                "--directory",
                workdir,
            ]
        )
        # import pdb; pdb.set_trace()

        # Check the output byte by byte using cmp.
        # To modify this behavior, you can inherit from common.OutputChecker in here
        # and overwrite the method `compare_files(generated_file, expected_file),
        # also see common.py.
        common.OutputChecker(data_path, expected_path, workdir).check()
