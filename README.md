# Current workflow

This will be updated as pieces are developed and modified.

```mermaid
%%{init: { 'theme':'neutral' } }%%
flowchart TB
    gisaid[(GISAID)] -.-> GISAIDR --> FASTA{FASTA}
    click GISAIDR href "https://github.com/Wytamma/GISAIDR"

    subgraph "Other data sources (TBD)"
        style preprocessing stroke-width: 2, stroke: grey,stroke-dasharray: 5 5
        otherSources[(DB)] -.-> preprocessing
    end 
    preprocessing --> FASTA --> MSA

    subgraph treeConstruction["Tree construction"]
        MSA[multiple sequence alignment<br/>-- MAFFT] --> tree[L_max tree<br/>-- Iqtree2] --> RTR[root-tip regression<br/>-- TempEst]
        click MSA href "https://github.com/GSLBiotech/mafft"
        click tree href "https://github.com/iqtree/iqtree2"
        click RTR href "https://github.com/beast-dev/Tempest"
    end

    subgraph QC["Quality control"]
        dummy[List of heuristics to be developed]
    end
    treeConstruction --> QC

    MSA --> XML[Beast XML generation<br/>-- Wytamma's scripts + templates + FEAST] --> OnlineBEAST[run, pause & update BEAST analysis<br/>-- Online BEAST] --> Beastiary[monitor running BEAST jobs<br/>-- Beastiary]
    click XML href "https://github.com/Wytamma/real-time-beast-pipeline"
    click OnlineBEAST href "https://github.com/Wytamma/online-beast"
    click Beastiary href "https://github.com/Wytamma/beastiary"
```

