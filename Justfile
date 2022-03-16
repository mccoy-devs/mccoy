run profile *args:
    ./snakemake --profile config/{{ profile }} {{ args }} -R `./snakemake --list-params-changes {{ args }}`

clean profile:
    #!/usr/bin/env sh
    set -euo pipefail

    ./snakemake --profile config/{{ profile }} -c 1 --delete-all-output --rerun-incomplete -n

    read -p "Do you want to continue? " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        exit 1

    fi
    ./snakemake --profile config/{{ profile }} -c 1 --delete-all-output --rerun-incomplete
