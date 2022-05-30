# Usage

The workflow is being developed such that all required software will be automatically installed for each step of the pipeline in self-contained conda environments. These environments will be cached and reused whenever possible (all handled internally by snakemake), but if you want to remove them then they can be found in `.snakemake`.

To run with the default parameters and configuration:

```bash
GISAIDR_USERNAME='_YOUR_USERNAME_' GISAIDR_PASSWORD='_YOUR_PASSWORD_' just run local -c 1
```

The parameters passed to each tool in the workflow can be changed by making a copy of the default config file and modifying it appropriately:

```bash
cp config/config.yml custom-config.yml
# modify custom-config.yml as required
GISAIDR_USERNAME='_YOUR_USERNAME_' GISAIDR_PASSWORD='_YOUR_PASSWORD_' just run local -c 1
```

On Spartan:

```bash
GISAIDR_USERNAME='_YOUR_USERNAME_' GISAIDR_PASSWORD='_YOUR_PASSWORD_' just run spartan
```
