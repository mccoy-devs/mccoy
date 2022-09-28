Running on HPC
==============

McCoy comes set up to easily run on any HPC system with a `SLURM`_ job scheduler.

.. note::

   You will still need to satisfy the :ref:`requirements for installing and
   running McCoy <prerequisites>`, namely Python & Mamba. These are provided as
   pre-installed "modules" on many HPC systems. Please consult the
   documentation for your system for more information.

**TL;DR**
---------

1. Set up your ``config.yaml`` appropriately (see the :ref:`example <hpc-example>` below).
2. Run McCoy with ``mccoy run <project_dir> --hpc``


Configuring your project
------------------------

In order to run on such a system, you will almost certainly need to modify your project ``config.yaml`` to provide system specific information on your user account / project, queue, etc. McCoy allows you to set any of the following `Snakemake resource values <https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html#resources>`_ on a global or per-rule basis:

``account`` (default: ``''``)
    Typically the "project" ID associated with your research.

``partition`` (default: ``''``)
    The queue partition to which your job will be sent.
    
``time`` (default: ``00:15:00``)
    The maximum wallclock time to request for a single job.

``mem`` (default: ``4G``)
    The amount of memory (RAM) to request **per-node** for each job.

``nodes`` (default: ``1``)
    The total number of nodes to request for a single job.

``tasks_per_node`` (default: ``1``)
    The total number of SLURM tasks per job. Unless you are running an MPI job, you should always set this to ``1``.

``qos`` (default: ``''``)
    The SLURM Quality Of Service value. Sometimes used when requesting generic resources (e.g. GPUs).

``gres`` (default: ``''``)
    May be used to request Generic RESources (e.g. GPUs)

``extra`` (default: ``''``)
    Any extra flags and options to be passed to the SLURM ``sbatch`` command.

In addition the SLURM ``cpus_per_task`` value is set by McCoy to be the Snakemake rule ``threads`` value. You can also pass required environment modules using the ``envmodules`` key in ``config.yaml``

.. warning::

   When discussing "threads" and "cores", we attempt to remain as close to the
   definitions of `Snakemake <https://snakemake.github.io>`_ as possible.
   However, the Snakemake definitions can be quite confusing and the meaning of
   "thread" changes depending on the context (e.g. running on a cluster or
   locally). If in doubt, we recommend always treating a "thread" as a physical
   cpu-core unless you have a specific reason not to and know what you are
   doing. This is the default definition in McCoy.

.. tip::

    To see exactly how McCoy takes all of this information and passes it to
    SLURM, you can look at `the relevant Snakemake profile here
    <https://github.com/mccoy-devs/mccoy/blob/main/mccoy/profiles/slurm/config.yaml>`_.


.. _hpc-example:

Example
-------

.. highlight:: yaml

The following example shows how you would alter the project config to employ 16 cores and 1 GPU with Beast2 on the University of Melbourne's Spartan HPC System::

    all:
      update_default_resources:
        account: "<my project id>"

    ...

    beast:
      threads: 16
      resources:
        time: "20:00:00"
        mem: "16G"
        partition: gpgpu
        gres: "gpu:1"
        qos: gpgpumdhs
      envmodules:
        - "gcccore/8.3.0"
        - "fosscuda/2019b"

.. _SLURM: https://slurm.schedmd.com
