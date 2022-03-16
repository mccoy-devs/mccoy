#!/usr/bin/env sh
set -euo pipefail

# configfile_opt=""
# if [ -n "${CONFIGFILE-}" ]; then
#     configfile_opt="--configfile=${CONFIGFILE}"
# fi

./snakemake --profile config/$1 ${@:2} -R `./snakemake --list-params-changes ${@:2}`
