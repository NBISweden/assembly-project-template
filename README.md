# Template instructions

1. Use this template to structure a repository for assembly projects.

   [PLEASE read the instructions](https://nbisweden.github.io/assembly-project-template/) on how to use it! 

2. Update this `README.md` with the project and species information.

# {{PROJECT_ID}} *de novo* genome assembly

{{PROJECT_DESCRIPTION}}

## Project responsible

- Name: From - Until
## General Info

* Project: {{PROJECT_SOURCE}}
* Species: {{SPECIES_FULL_SCIENTIFIC_NAME}} ({{SPECIES_FULL_TRIVIAL_NAME}})
* Estimated genome size: {{GENOME_SIZE}}
* Classification: [NCBI taxonomy](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id={{NCBI_TAXONOMY_ID}})
* NCBI taxonomy ID: {{NCBI_TAXONOMY_ID}}
* ToLID: {{SANGER_TOLID}}

![{{SPECIES_FULL_SCIENTIFIC_NAME}}](docs/images/{{SPECIES_ID}}.jpg)

## Project organisation

*analyses*:
Launch workflows
*code*: 
Adhoc scripts and workflows
*data*:
Workflow inputs and outputs
*docs*:
Any kind of documentation
*envs*:
Custom environments

## Working in multiple places

Use `git clone` to clone the project repository on both your laptop and the hpc from Github. 

Then on your laptop, link your hpc cloned repo with your laptop like:
```bash
git remote add hpc user@cluster:/path/to/cloned/repo/on/hpc
```
If you have set up your ssh config with this information, then you can replace the
`user@cluster` with your hpc cluster alias.

This allows you to fetch files locally with pixi tasks (which takes advantage of `git remote get-url hpc`)
