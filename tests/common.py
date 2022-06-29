"""
Common code for unit testing of rules generated with Snakemake 7.8.3.
"""

import os
import subprocess as sp
from pathlib import Path


class OutputChecker:
    def __init__(self, data_path, expected_path, workdir, ignore=None):
        self.data_path = data_path
        self.expected_path = expected_path
        self.workdir = workdir
        self.ignore = [] if ignore is None else ignore

    def check(self):
        input_files = set(
            (Path(path) / f).relative_to(self.data_path)
            for path, subdirs, files in os.walk(self.data_path)
            for f in files
        )
        expected_files = set(
            (Path(path) / f).relative_to(self.expected_path)
            for path, subdirs, files in os.walk(self.expected_path)
            for f in files
        )
        unexpected_files = set()
        for path, subdirs, files in os.walk(self.workdir):
            for f in files:
                f = (Path(path) / f).relative_to(self.workdir)
                if str(f).startswith(".snakemake") or str(f).startswith("logs/") or str(f) in self.ignore:
                    continue
                if f in expected_files:
                    self.compare_files(self.workdir / f, self.expected_path / f)
                elif f in input_files:
                    # ignore input files
                    pass
                else:
                    unexpected_files.add(f)
        if unexpected_files:
            raise ValueError("Unexpected files:\n{}".format("\n".join(sorted(map(str, unexpected_files)))))

    def compare_files(self, generated_file, expected_file):
        try:
            sp.check_output(["cmp", generated_file, expected_file])
        except sp.CalledProcessError as err:
            print(err.output.decode("utf8"))
            raise ValueError
