#!/usr/bin/env sh
set -euo pipefail

configfile_opt=""
if [ -n "${CONFIGFILE-}" ]; then
    configfile_opt="--configfile=${CONFIGFILE}"
fi

snakemake --use-conda ${configfile_opt} $* -R `snakemake --list-params-changes ${configfile_opt}`
