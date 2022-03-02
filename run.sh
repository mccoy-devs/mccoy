#!/usr/bin/env sh

# Not necessary if using the default config file, but this way we can override easily...
configfile="${CONFIGFILE:-config/config.yml}"

snakemake --use-conda --configfile ${configfile} $* -R `snakemake --list-params-changes --configfile ${configfile}`
