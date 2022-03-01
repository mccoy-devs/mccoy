#!/usr/bin/env sh

configfile=config-tmp.yml
ncores=1

snakemake -c${ncores} --use-conda --configfile ${configfile} -R `snakemake --list-params-changes --configfile ${configfile}`
