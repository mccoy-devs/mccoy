# Current workflow

[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/smutch/mccoy/main.svg)](https://results.pre-commit.ci/latest/github/smutch/mccoy/main)
[![docs](https://github.com/smutch/mccoy/actions/workflows/docs.yaml/badge.svg?event=push)](https://github.com/smutch/mccoy/actions/workflows/docs.yaml)


This will be updated as pieces are developed and modified.

**Legend**:
- <span style="color: #48b884">initial support in the workflow</span>
- <span style="color: #cc8400">in progress</span>

```mermaid
%%{init: { 'theme':'neutral' } }%%
flowchart TB
    gisaid[(GISAID)] -.-> GISAIDR --> FASTA{FASTA}
    click GISAIDR href "https://github.com/Wytamma/GISAIDR"

    subgraph "Other data sources"
        otherSources[(input/ directory)]
    end
    otherSources --> FASTA --> MSA

    subgraph treeConstruction["Tree construction"]
        MSA[multiple sequence alignment<br/>-- MAFFT] --> tree[L_max tree<br/>-- iqtree2] --> RTR[root-tip regression<br/>-- TempEst]
        click MSA href "https://github.com/GSLBiotech/mafft"
        click tree href "https://github.com/iqtree/iqtree2"
        click RTR href "https://gitlab.unimelb.edu.au/mdap-public/duchene-mdap-2022/-/issues/2"
    end

    subgraph QC["Quality control"]
        dummy[See GitLab issue]
        click dummy href "https://gitlab.unimelb.edu.au/mdap-public/duchene-mdap-2022/-/issues/3"
    end
    treeConstruction --> QC

    MSA --> XML[Beast XML generation<br/>-- Wytamma's scripts + templates + FEAST] --> OnlineBEAST[run, pause & update BEAST analysis<br/>-- Online BEAST] --> Beastiary[monitor running BEAST jobs<br/>-- Beastiary]
    click XML href "https://github.com/Wytamma/real-time-beast-pipeline"
    click OnlineBEAST href "https://github.com/Wytamma/online-beast"
    click Beastiary href "https://github.com/Wytamma/beastiary"

    classDef complete fill:#48b884;
    class gisaid,GISAIDR,otherSources,FASTA,MSA,tree complete;

    classDef inProg fill:#cc8400;
    class RTR,QC,XML inProg;
```

# Instructions

Ensure you have [mamba](https://github.com/conda-forge/miniforge) (conda will work too, but mamba is strongly preferred), and [poetry](https://python-poetry.org) installed.

## Step 1 - install the workflow

```bash
poetry install
```

## Step 2 - run the workflow

The workflow is being developed such that all required software will be automatically installed for each step of the pipeline in self-contained conda environments. These environments will be cached and reused whenever possible (all handled internally by snakemake), but if you want to remove them then they can be found in `.snakemake`.

> Note that you can remove the need for `poetry run` everywhere below by first running `poetry shell` to start a new shell with the mccoy poetry project loaded.

First begin by creating a new Beastflow project (called `test` in this example):

```bash
poetry run mccoy create test --reference mccoy/resources/reference.fasta --template mccoy/resources/templates/CoV_CE_fixed_clock_template.xml
```

The config for this project can be altered by editing the newly created file `test/config.yaml`.

To run the newly created project:

```bash
poetry run mccoy run test --data mccoy/resources/omicron_test-original.fasta
```

This will create a new directory in `test/runs` with the workflow results and output. Subsequent calls to `poetry run mccoy run` will result in a whole new run of the pipeline from start-to-finsh unless the `--inherit` or `--inherit-last` flags are used. See `poetry run mccoy run --help` for more information.

As well as directly altering a project's `config.yaml`, config variables can be overridden on the command line. e.g.:
```bash
GISAIDR_USERNAME='_YOUR_USERNAME_' GISAIDR_PASSWORD='_YOUR_PASSWORD_' poetry run mccoy run --data mccoy/resources/omicron_test-original.fasta --config query.enabled=true
```

Any options passed to `poetry run mccoy run` that are not listed in `poetry run mccoy run --help` will be directly forwarded on to snakemake. See `poetry run mccoy run --help-snakemake` for a list of all available options.
