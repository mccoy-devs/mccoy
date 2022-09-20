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

.. code-block:: yaml
   
   TODO

.. _Mamba: https://github.com/mamba-org/mamba
.. _Beast2: http://www.beast2.org
