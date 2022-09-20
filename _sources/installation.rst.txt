Installation
============

Prerequisites
-------------

McCoy wraps `Snakemake`_ and installs all required third-party tools (e.g. `Beast2 <http://www.beast2.org>`_, `IQ-TREE <http://www.iqtree.org>`_, ...) into isolated environments using `Conda`_.
For this reason, we also require either the `Conda`_ or `Mamba`_  package managers to be installed on your system (with a strong preference for the latter).

If you don't have either, `Mamba`_ can be easily installed via the `Mambaforge`_ distribution.
If you already have `Conda`_ installed on your system, you can instead install `Mamba`_ using::

    conda install -n base -c conda-forge mamba


Installing McCoy
----------------

McCoy is available via `pypi <https://pypi.org/project/mccoy/>`_ and can be installed using `pip <https://pip.pypa.io/en/stable/>`_::

    pip install mccoy



.. _Snakemake: https://snakemake.github.io
.. _Conda: https://docs.conda.io/en/latest/
.. _Mamba: https://github.com/mamba-org/mamba
.. _Mambaforge: https://github.com/conda-forge/miniforge#mambaforge
