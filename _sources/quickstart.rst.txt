.. highlight-push::

.. highlight:: bash

Quick-start
===========

.. warning::

   This page is under construction!

Install McCoy
-------------

If you haven't done so yet, install McCoy and `Mamba`_ following the :doc:`installation <installation>` instructions.


Create a project
----------------

A new project can be created using::

    mccoy create <project_name> \
        --reference <reference_fasta_file> \
        --template <beast2_template_file>

Where ``<project_name>``, ``<reference_fasta_file>``, and ``<beast2_template_file>`` are replaced appropriately.

A new directory will be created with the following contents::

    ├── config.yaml            # <- A configuration file, used to tweak the
    │                          #    parameters of each step in the pipeline
    ├── resources
    │   ├── reference.fasta    # <- Copy of the reference genome
    │   └── template.xml       # <- Copy of the Beast2 template
    │
    ├── runs                   # <- An empty directory where runs will be stored
    └── tests.py               # <- Bare-bones quality control test suite



Configure your project
----------------------

Due to the large diversity in possible phylodynamic analyses, you will almost certainly need to customise the McCoy project to fit your needs.
McCoy has been designed so that as much of that customisation as possible can be made using the project ``config.yaml`` or command line arguments.

The default config file looks something like this:

.. literalinclude:: ../mccoy/config/config.yaml
   :caption: Config options applied to all workflow rules
   :linenos:
   :lineno-match:

Let's break down some of the key sections...

The first block is called ``all`` and applies to all rules in the workflow. It allows setting the absolute maximum number of threads / cores used by any single rule on a single machine / node, regardless of what is available (``threads_max``). If you are running on an HPC system and want to make use of nodes with more than 64 cores then you may want to raise this value.

.. warning::

   When discussing "threads" and "cores", we attempt to remain as close to the
   definitions of `Snakemake`_ as possible. However, the Snakemake definitions
   can be quite confusing and the meaning of "thread" changes depending on the
   context (e.g. running on a cluster or locally). If in doubt, we recommend
   always treating a "thread" as a physical cpu-core unless you have a specific
   reason not to and know what you are doing. This is the default definition in
   McCoy.

.. highligh-push::

.. highlight:: yaml

When running on an HPC cluster, you can also use ``update_default_resources`` to set defaults for the requested resources of all of your jobs. This is very useful to, for example, set the default account to which your resource usage will be charged::

    update_default_resources:
      - account='proj00577'

After this, we have one config block for each rule of the workflow with options: :smk:ref:`align`, :smk:ref:`tree`, and :smk:ref:`beast`. See the documentation for each of these rules for information about the available config parameters.

One key parameter which you will see repeated is ``threads``. When running locally, this corresponds to the maximum number of CPU cores allocated (remembering that we will never exceed ``all.threads_max``). This value will automatically be adjusted to the total number of cores available on the machine if more than that number is requested. When running on an HPC cluster, McCoy uses ``threads`` to set the `SLURM`_ ``cpus-per-task`` value [[#f1]_].

.. [#f1] In other words, we use threads to set the amount of "shared-memory" parallelism.

.. _Mamba: https://github.com/mamba-org/mamba
.. _Beast2: http://www.beast2.org
.. _Snakemake: https://snakemake.github.io
.. _SLURM: https://slurm.schedmd.com
