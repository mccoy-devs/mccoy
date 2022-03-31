# Installation

Ensure you have [mamba](https://github.com/conda-forge/miniforge) installed (conda will work too, but mamba is strongly preferred).

If you already have [snakemake](https://snakemake.readthedocs.io/en/stable/) and [just (a command runner)](https://github.com/casey/just) installed then go straight to step 2! Otherwise...

In the base directory of the repo, you can create a fresh conda environment with:

```bash
mamba env create -f environment.yml
```

This only needs to be done once.

You can then activate the environment using `conda activate duchene-mdap-2022`. This will need to be done for each fresh terminal you open if you want to use snakemake.