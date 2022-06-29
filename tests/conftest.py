import difflib
import hashlib
import shutil
import subprocess as sp
from pathlib import Path
from typing import List, NewType, Optional, Union

import pytest
import typer

TargetsType = NewType("TargetsType", Union[str, Path, List[Union[str, Path]]])


class FilesDiffer(Exception):
    pass


def _md5sum(filename):
    md5 = hashlib.md5()
    with open(filename, 'rb') as f:
        for chunk in iter(lambda: f.read(128 * md5.block_size), b''):
            md5.update(chunk)
    return md5.hexdigest()


def _targets_to_pathlist(pathlist: TargetsType) -> List[Path]:
    if isinstance(pathlist, (Path, str)):
        pathlist = [pathlist]
    for ii, path in enumerate(pathlist):
        if isinstance(path, str):
            pathlist[ii] = Path(path)
    return pathlist


class Workflow:
    def __init__(self, targets: List[Path], work_dir: Path, expected_dir: Path):
        self.targets = targets
        self.work_dir = work_dir
        self.expected_dir = expected_dir

    def assert_expected(self, expected_files: Optional[TargetsType] = None, diff_on_fail: bool = True) -> bool:
        if expected_files is None:
            expected_files = self.targets
        else:
            expected_files = _targets_to_pathlist(expected_files)

        expected_files: List[Path]

        # Check expected files
        for expected_file in expected_files:
            generated_path = self.work_dir / expected_file
            expected_path = self.expected_dir / expected_file

            if _md5sum(generated_path) == _md5sum(expected_path):
                continue

            # If different then write the diff
            if diff_on_fail:
                with open(generated_path) as generated, open(expected_path) as expected:

                    generated_lines = generated.readlines()
                    expected_lines = expected.readlines()

                    diff = difflib.unified_diff(generated_lines, expected_lines)

                    for line in diff:
                        if line.startswith('+'):
                            fg = typer.colors.GREEN
                        elif line.startswith('-'):
                            fg = typer.colors.RED
                        elif line.startswith('^'):
                            fg = typer.colors.BLUE
                        else:
                            fg = None

                        typer.secho(line.rstrip(), fg=fg)

                raise FilesDiffer(f"'{expected_file}' does not match expected.")

        return True


@pytest.fixture
def run_workflow(tmpdir: Path):
    def _run_workflow(targets: TargetsType) -> Workflow:
        targets = _targets_to_pathlist(targets)

        work_dir = Path(tmpdir) / "expected"
        tests_dir = Path(__file__).parent
        expected_dir = tests_dir / "expected"

        # Symlink the expected result into the workdir recursively (rather than a single link for the whole tree) so we
        # can overwrite things and not affect our expected results.
        shutil.copytree(
            expected_dir,
            work_dir,
            # copy_function=shutil.copy,
            ignore=shutil.ignore_patterns('.snakemake', '.conda'),
        )

        sp.check_output(
            [
                "mccoy",
                "run",
                work_dir,
                "--data",
                Path(__file__).parent.resolve() / "data.fasta",
                "-j1",
                "-f",
                "--keep-target-files",
                # f"--conda-base-path={Path(__file__).parent.resolve() / '.conda'}",
                "--continue",
                "--verbose",
                *targets,
            ],
        )

        run_dir = "runs/run_1"
        return Workflow(targets, work_dir / run_dir, expected_dir / run_dir)

    return _run_workflow
