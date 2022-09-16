.. toctree::
   :hidden:
   :maxdepth: 3

   intake
   alignment
   quality_control
   beast
   report


McCoy
=====

.. warning::

   These docs are a work-in-progress!


Workflow overview
-----------------

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


Contents
--------

* :ref:`intake_module`
* :ref:`alignment_module`
* :ref:`quality_control_module`
* :ref:`beast_module`
* :ref:`report_module`
* :ref:`All rules<smk-rule>`
