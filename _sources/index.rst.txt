.. toctree::
   :hidden:
   :maxdepth: 2

   rules


McCoy
=====

.. warning::

   These docs are not complete or up-to-date. Stay tuned for that!


Workflow overview
-----------------

.. mermaid::

    %%{init: { 'theme':'neutral' } }%%
    flowchart TB
        sources[(fasta files)]
        sources --> combine --> MSA
        click combine href "rules.html#rule-combine"

        MSA["multiple sequence alignment"] --> QC
        click MSA href "rules.html#alignment"

        subgraph QC["Quality control"]
            direction TB
            tree[maximum likelihood tree] --> RTR[root-tip regression]
            click tree href "rules.html#tree-construction"
            otherQC[other checks]
        end

        QC --> Beast

        subgraph Beast
            direction TB
            XML["XML generation"] --> OnlineBEAST["run, pause & update data"]
            click XML href "rules.html#dynamicbeast"
            click OnlineBEAST href "rules.html#onlinebeast"
        end


All rules
---------

* :ref:`Index<smk-rule>`
