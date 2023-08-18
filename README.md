# McCoy

<div style="text-align: center; font-style: italic;">
<img src="https://mccoy-devs.github.io/mccoy/_images/mccoy-logo.svg" width="30%"><br>
<it>a complete workflow for close-to-real-time bayesian phylodynamic analyses</it>
</div>

[![pypo](https://img.shields.io/pypi/v/mccoy.svg)](https://pypi.org/project/mccoy/)
[![tests](https://github.com/mccoy-devs/mccoy/actions/workflows/tests.yaml/badge.svg)](https://github.com/mccoy-devs/mccoy/actions/workflows/tests.yaml)
[![docs](https://github.com/smutch/mccoy/actions/workflows/docs.yaml/badge.svg?event=push)](https://mccoy-devs.github.io/mccoy/)
[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/smutch/mccoy/main.svg)](https://results.pre-commit.ci/latest/github/smutch/mccoy/main)


# Quickstart

For a complete quickstart guide, check out [the docs](https://mccoy-devs.github.io/mccoy/quickstart.html).

## Prerequisites

Ensure you have [mamba](https://github.com/conda-forge/miniforge) installed (conda will work too, but mamba is strongly preferred).
McCoy wraps [Snakemake](https://snakemake.github.io) and installs all required third-party tools (e.g. [Beast2](http://www.beast2.org), [IQ-TREE](http://www.iqtree.org), etc.) into isolated environments using one of these tools. For more information see the [installation page](https://mccoy-devs.github.io/mccoy/installation.html) of the docs.

## Install McCoy

```bash
pip install mccoy
```

## Create a McCoy project

First begin by creating a new McCoy project (called `test_project` in this example):

```bash
mccoy create test_project --reference reference.fasta --template template.xml
```

The `reference` and `template` options are required. For testing purposes you can use the `reference.fasta` and `template.xml` files provided as part of our [test suite here](https://github.com/mccoy-devs/mccoy/tree/main/tests).

## Configure the project

Configure the project by editing the newly created file `test_project/config.yaml`. See [the docs](https://mccoy-devs.github.io/mccoy/quickstart.html) for more information.

## Run the project

To run the newly created project:

```bash
mccoy run test --data data.fasta
```
This command will create a new directory in `test/runs` with the workflow results and output.
Again, the `data` option here is required and for testing purposes, the `data.fasta` file from our [test suite](https://github.com/mccoy-devs/mccoy/tree/main/tests) can be used.

## Step 4 - Add new data

Subsequent calls to `mccoy run` will result in a whole new run of the pipeline from start-to-finsh unless the `--inherit` or `--inherit-last` flags are used. See `mccoy run --help` and [the docs](https://mccoy-devs.github.io/mccoy/quickstart.html) for more information. Inheriting from a previous run will use its data and MCMC state as a starting point for the new run.

```bash
mccoy run test --data data2.fasta --inherit-last
```

As well as directly altering a project's `config.yaml`, config variables can be overridden on the command line. e.g.:
```bash
mccoy run --data resources/omicron_test-original.fasta --config align='{mafft: ["--6merpair", "--addfragments"]}'
```

Any options passed to `mccoy run` that are not listed in `mccoy run --help` will be directly forwarded on to Snakemake. See `mccoy run --help-snakemake` for a list of all available options.

Finally, a local copy of the workflow can be created by passing `--copy-workflow` to `mccoy create` when initialising a new project. This local copy will be automatically used by any subsequent calls to `mccoy run`, allowing the workflow to be fully altered and customised as required.

# Next steps

The full documentation can be [found here](https://mccoy-devs.github.io/mccoy/index.html).
