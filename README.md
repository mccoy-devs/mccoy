# Current workflow

This will be updated as pieces are developed and modified.

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
        click RTR href "https://github.com/beast-dev/Tempest"
    end

    subgraph QC["Quality control"]
        dummy[List of heuristics to be developed]
    end
    treeConstruction --> QC

    MSA --> XML[Beast XML generation<br/>-- Wytamma's scripts + templates + FEAST] --> OnlineBEAST[run, pause & update BEAST analysis<br/>-- Online BEAST] --> Beastiary[monitor running BEAST jobs<br/>-- Beastiary]
    click XML href "https://github.com/Wytamma/real-time-beast-pipeline"
    click OnlineBEAST href "https://github.com/Wytamma/online-beast"
    click Beastiary href "https://github.com/Wytamma/beastiary"
```

# Instructions

Ensure you have [mamba](https://github.com/conda-forge/miniforge) installed (conda will work too, but mamba is strongly preferred).

## Step 1 - install snakemake

If you already have [snakemake](https://snakemake.readthedocs.io/en/stable/) installed then go straight to step 2! Otherwise...

In the base directory of the repo, you can create a fresh conda environment with:

```bash
mamba env create -f environment.yml
```

This only needs to be done once.

You can then activate the environment using `conda activate duchene-mdap-2022`. This will need to be done for each fresh terminal you open if you want to use snakemake.

## Step 2 - run the workflow

The workflow is being developed such that all required software will be automatically installed for each step of the pipeline in self-contained conda environments. These environments will be cached and reused whenever possible (all handled internally by snakemake), but if you want to remove them then they can be found in `.snakemake`.

Right now, there are no options for running the workflow. This will obviously change in future.

To run:

```bash
GISAIDR_USERNAME='_YOUR_USERNAME_' GISAIDR_PASSWORD='_YOUR_PASSWORD_' snakemake --use-conda -c 1
```
