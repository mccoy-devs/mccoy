Workflow
========

Overview
--------
.. admonition:: TODO
   :class: seealso

   A general overview of the workflow.

.. tip::
   You can clik on the workflow nodes below to see the documentation for the relevant rules.

.. mermaid::

    %%{init: { 'theme':'neutral' } }%%
    flowchart TB
        subgraph intake["Intake module"]
            sources[(fasta files)]
            sources --> combine
        end
        click sources,combine href "intake.html"
        combine --> alignment

        subgraph alignment["Alignment module"]
            MSA
        end
        click MSA href "alignment.html"
        alignment --> report

        MSA["multiple sequence alignment"] --> QC

        subgraph QC["Quality control module"]
            direction TB
            tree[maximum likelihood tree] --> phytest[Phytest checks]
        end
        click tree href "quality_control.html#tree"
        click phytest href "quality_control.html#phytest"

        QC --> Beast
        QC --> report

        subgraph Beast["Beast module"]
            direction TB
            XML["dynamic XML generation"] --> OnlineBEAST["add new sequences to previous run"] --> BEAST2
            click XML href "beast.html#dynamicbeast"
            click OnlineBEAST href "beast.html#onlinebeast"
            click BEAST2 href "beast.html#beast"
        end

        Beast --> report{{Report generation}}
        click report href "report.html"


Modules & Rules
---------------

.. toctree::
   :maxdepth: 1

   intake
   alignment
   quality_control
   beast
   report
   smk-rule


Modifying the workflow
----------------------

.. highlight:: sh

When creating a McCoy project, you can optionally create a local copy of the
`Snakemake`_ workflow and use this for your runs. This allows complete control
over every rule and arbitrary modification of the pipeline::

    mccoy create <project_name> \
        --reference <reference_fasta_file> \
        --template <beast2_template_file>
        --copy-workflow

The addition of the ``--copy-workflow`` flag will result in a new directory
called ``workflow`` being placed in the project directory. This contains a
complete copy of the Snakemake workflow that can be edited as needed. Any
future use of the ``mccoy run`` command will automatically use this local copy.


.. _Snakemake: https://snakemake.github.io
