.. toctree::
   :hidden:
   :maxdepth: 2

   rules
   intake
   alignment


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

        subgraph alignment["Alignment module"]
            MSA
        end
        combine --> alignment
        click MSA href "alignment.html"

        MSA["multiple sequence alignment"] --> QC

        subgraph QC["Quality control module"]
            direction TB
            tree[maximum likelihood tree] --> phytest[Phytest checks]
        end
        click tree href "quality_control.html#tree"
        click phytest href "quality_control.html#phytest"

        QC --> Beast

        subgraph Beast["Beast module"]
            direction TB
            XML["dynamic XML generation"] --> OnlineBEAST["add new sequences to previous run"] --> BEAST2
            click XML href "beast.html#dynamicbeast"
            click OnlineBEAST href "beast.html#onlinebeast"
            click BEAST2 href "beast.html#beast"
        end


Contents
--------

* :ref:`intake_module`
* :ref:`alignment_module`
* :ref:`All rules<smk-rule>`
