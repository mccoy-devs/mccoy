:tocdepth: 3

.. _beast_module:

Beast module
============

This module contains the rules to generate dynamic beast XML input files, update previous BEAST analyses with new samples, run BEAST2 and produce summary plots and statistics for the McCoy report.

Rules
-----

.. smk:autodoc:: ../mccoy/workflow/Snakefile dynamicbeast onlinebeast beast plot_traces arviz max_clade_credibility_tree max_clade_credibility_tree_newick max_clade_credibility_tree_render
