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
        workdir = Path(tmpdir) / "project"
        data_path = PurePosixPath("tree/data")
        expected_path = PurePosixPath("tree/expected")

        # Create the McCoy project in the temporary workdir
        sp.check_output(
            [
                "mccoy",
                "create",
                workdir,
                "--reference",
                "project/resources/reference.fasta",
                "--template",
                "project/resources/template.xml",
            ]
        )

        # Copy data to the temporary workdir
        # WARNING: Note the use of the copy function here.
        #          This is necessary to not confuse snakemake with timestamps!
        shutil.copytree(data_path, workdir / "runs/run_1", copy_function=shutil.copy)

        # Run the test job.
        print(
            sp.check_output(
                [
                    "mccoy",
                    "run",
                    workdir,
                    "--data",
                    Path(__file__).parent.resolve() / "data.fasta",
                    "-j1",
                    "-f",
                    "--keep-target-files",
                    f"--conda-base-path={Path(__file__).parent.resolve() / '.conda'}",
                    "--continue",
                    "--verbose",
                    "results/tree/project-1.fasta.treefile",
                    "results/tree/project-1.fasta.bionj",
                    "results/tree/project-1.fasta.ckp.gz",
                    "results/tree/project-1.fasta.contree",
                    "results/tree/project-1.fasta.iqtree",
                    "results/tree/project-1.fasta.log",
                    "results/tree/project-1.fasta.mldist",
                    "results/tree/project-1.fasta.splits.nex",
                ],
            ).decode("utf-8")
        )

        # Check the output byte by byte using cmp.
        # To modify this behavior, you can inherit from common.OutputChecker in here
        # and overwrite the method `compare_files(generated_file, expected_file),
        # also see common.py.
        common.OutputChecker(
            data_path,
            expected_path,
            workdir / "runs/run_1",
            ignore=[
                "results/tree/project-1.fasta.iqtree",
                "results/tree/project-1.fasta.log",
            ],
        ).check()
