```
  __  __       _____
 |  \/  |     / ____|
 | \  / | ___| |     ___  _   _
 | |\/| |/ __| |    / _ \| | | |
 | |  | | (__| |___| (_) | |_| |
 |_|  |_|\___|\_____\___/ \__, |
                           __/ |
                          |___/ 
```

This project was created with the [McCoy](https://github.com/mccoy-devs/mccoy) CLI.


# Project layout

Here you will find the following files and directories:

1. `config.yaml`: The configuration file for this project. You can use
   this to change the command line arguments and options for your runs. See the
   docs for more information.

2. `tests.py`: [Phytest](https://github.com/phytest-devs/phytest) quality
   control checks that will be run as part of the pipeline. This will also
   need to be adapted to suit your particular usecase and needs.

3. `resources`: This directory contains the reference sequence and BEAST2
   template which was provided during project creation.

4. `runs`: This is where each run of McCoy will be stored (see below).


# Running McCoy

To run McCoy from within this directory:

```
mccoy run . --data <PATH TO YOUR FASTA FILE>
```

To see a list of other options which can be passed to McCoy, run
`mccoy run --help`. Any unrecognised arguments will be forwarded on to
Snakemake. A full list of possible snakemake arguments can be found
by running `mccoy run --help-snakemake`.
