# Analyses

This folder aims to contain all the scripts needed to launch all analyses performed for the
duration of this project. Each subfolder corresponds to a specific analysis, with a parameter file, 
configuration file, and launch script. The launch script may run a workflow (e.g., Nextflow, Snakemake, etc), 
a notebook (e.g., Quarto, Jupyter, RMarkdown, etc), or custom scripts (e.g., Bash, Python, etc) which form 
an analysis. It is important that a computation environment is activated when launching an analysis, 
either through explicit activation, or using a configuration file. The folder name should also indicate
where the analysis is supposed to be run (Rackham, NAC, local)

A `Roadmap.md` file is used to communicate how analyses relate to each other. 
For example:
- which folders run the same workflow but with different parameters.
- which folders run subsequent analyses to another folder.
- which folders result in useful data, were abandoned/unfinished, or the resulting 
data were of little use. 
- which folders use test data and/or develop workflows, and which folders run analyses on the full data sets.


Initial folder structure:

```
analyses
  | - README.md                                 (This file)
  | - Roadmap.md                                (For longer projects, a roadmap of which analysis lead to what)
  |
  \ - 01_assembly-workflow_initial-run_rackham/ (Initial run of the assembly workflow)
        | - assembly_parameters.yml             (Parameter config for all data)
        | - nextflow.config                     (Optional: Additional Nextflow configuration)
        \ - run_nextflow.sh                     (Nextflow launch script)
```

Templates can be copied from `code/launch_templates`.
