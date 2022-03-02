#!/usr/bin/env sh

configfile=config/config.yml  # Not necessary if using the default config file, but this way we can override easily
ncores=1

snakemake -c${ncores} --use-conda --configfile ${configfile} $* -R `snakemake --list-params-changes --configfile ${configfile}`
