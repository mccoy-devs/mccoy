.. Phylodynamics Workflow documentation master file, created by
   sphinx-quickstart on Thu Mar 17 14:41:54 2022.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to Phylodynamics Workflow's documentation!
==================================================

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   installation
   usage

.. warning::

   These docs are not complete or up-to-date. Stay tuned for that!

.. smk:autodoc:: ../mccoy/workflow/Snakefile
   :config: project_path = ../tests/expected
            data = ../tests/data.fasta
            inherit = False
            id = run_1

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
