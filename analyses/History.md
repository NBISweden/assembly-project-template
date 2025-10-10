# Analysis history

This history file communicates the strategy followed to obtain the frozen results.
This is useful for longer projects to describe how and why certain analyses
were performed, and which analyses lead to what.

## Overview

Use a mermaid diagram to visually describe how folders relate each other.
A `flowchart` is an example that can be used to display the folder relationships.

```mermaid
flowchart TD
  01a[ 01_ebp-assembly-workflow ]:::green --> 02a[ 02_blobtoolkit ]:::green
  02a --> 03a[ 03_curationpretext ]:::green
  03a --> 04a[ 04_ear ]:::green
  classDef red stroke:#f00
  classDef green stroke:#0f0
```
