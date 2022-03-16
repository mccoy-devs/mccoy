# Current workflow

This will be updated as pieces are developed and modified.

**Legend**:
- <span style="color: #48b884">initial support in the workflow</span>
- <span style="color: #cc8400">in progress</span>

```mermaid
%%{init: { 'theme':'neutral' } }%%
flowchart TB
    gisaid[(GISAID)] -.-> GISAIDR --> FASTA{FASTA}
    click GISAIDR href "https://github.com/Wytamma/GISAIDR"

    subgraph "Other data sources (TBD)"
        style preprocessing stroke-width: 2, stroke: grey,stroke-dasharray: 5 5
        otherSources[(DB)] -.-> preprocessing
    end 
    preprocessing --> FASTA --> MSA

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
    class gisaid,GISAIDR,FASTA,MSA,tree complete;

    classDef inProg fill:#cc8400;
    class RTR,QC,XML inProg;
```

# Instructions

Ensure you have [mamba](https://github.com/conda-forge/miniforge) installed (conda will work too, but mamba is strongly preferred).

## Step 1 - install snakemake

If you already have [snakemake](https://snakemake.readthedocs.io/en/stable/) and [just (a command runner)](https://github.com/casey/just) installed then go straight to step 2! Otherwise...

In the base directory of the repo, you can create a fresh conda environment with:

```bash
mamba env create -f environment.yml
```

This only needs to be done once.

You can then activate the environment using `conda activate duchene-mdap-2022`. This will need to be done for each fresh terminal you open if you want to use snakemake.

## Step 2 - run the workflow

The workflow is being developed such that all required software will be automatically installed for each step of the pipeline in self-contained conda environments. These environments will be cached and reused whenever possible (all handled internally by snakemake), but if you want to remove them then they can be found in `.snakemake`.

To run with the default parameters and configuration:

```bash
GISAIDR_USERNAME='_YOUR_USERNAME_' GISAIDR_PASSWORD='_YOUR_PASSWORD_' just local -c 1
```

The parameters passed to each tool in the workflow can be changed by making a copy of the default config file and modifying it appropriately:

```bash
cp config/config.yml custom-config.yml
# modify custom-config.yml as required
GISAIDR_USERNAME='_YOUR_USERNAME_' GISAIDR_PASSWORD='_YOUR_PASSWORD_' just local -c 1
```

On Spartan:

```bash
GISAIDR_USERNAME='_YOUR_USERNAME_' GISAIDR_PASSWORD='_YOUR_PASSWORD_' just spartan
```
