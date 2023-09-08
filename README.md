# Assembly Project Template

This is a template for all assembly projects. Please read the instructions below
on how to use it.

## General Prerequisites on Rackham 

1. You need to have a recent git version
    ```sh
    # you might want to add this into your shell config file
    module load git/2.34.1
    ```
2. You need to have the git command line client ([gh](https://cli.github.com/)) in your PATH variable. Either by local installation, or via conda, or we might want to ask the Rackham administration guys to add this tool for us ?! 

3. You need the NBIS github access token (just ask Martin :)) and store it as `~/github_token.txt`. For safety reasons, especially on rackham, set the file permission to owner only: `chmod 700 ~/github_token.txt`.

## Install

1. Choose a [good project identifier](#choosing-a-project-identifier).
2. Copy the contents of this repository into your project folder:

   ```sh
   git clone --single-branch --recurse-submodules git@github.com:NBISweden/assembly-project-template.git <project-id>
   cd <project-id>
   rm -rf .git
   git init --shared=group .
   ```

3. Change into dir `scripts` and run `init-project.sh` to establish all mandatory meta data about
   the project.
   ```
   cd scripts
   bash init-project.sh
   ```

4. When PacBio bam files and xml files are present, run `scripts/setup_pacbioQC.sh`, giving the names of the relevant bam files when promted.

### Choosing a Project Identifier

The general format of a project identifier is

    {type}-{class}-Species_Name[-freeText]

The individual parts are:

- `{type}`:
    - `asm` for _de novo_ assemblies
    - `map` for reference guided/mapping-type projects.
    - `ano` annotation ? 
- `{class}`: Project class or category. For now we set up the following options:
    - `ERGA` for any project that relates to ERGA
    - `VREBP` for any project that relates to ERGA
    - `SMS` short term projects
    - `OTHER` any project that does not fit into one of the above categories
    The class determines to which github team the repository will be asscoiated with.
- `{freeText}`: Usually a aerial number or any other descriptive identifier in order to distinguish different projects concerning the same species (i.e. different individials). This is optional for `asm` projects and mandatory for `map`
  projects.

## Directory Structure Specification

The directory structure in the repository is as follows:

```
/
|-- assembly
|   |-- hifiasm
|   |-- hicanu
|   |-- canu
|   |-- lja
|   |-- ipa
|   |-- verkko
|   `-- flye
|-- rawdata
|   |-- illumina 
|       |-- 10x
|       |-- hic
|       |-- shotgun
|   |-- pacbio
|       |-- hifi
|       |-- isoseq
|       `-- lofi
|   |-- bionano
|   `-- ont
|-- data
|   |-- illumina 
|       |-- 10x
|       |-- hic
|       |-- shotgun
|   |-- pacbio
|       |-- hifi
|       |-- isoseq
|       `-- lofi
|   |-- bionano
|   `-- ont
|-- status
|-- reports
|-- scripts
|   `--pacbio_stats
`-- QC
    `-- pacbio
        `-- lofi
            |-- coverage
            `-- read_stats
```

The contents of each directory are specified in the following. Some of them need to be further defined.


### `/assembly`

There must be a folder for every assembly pipeline used in the project. Examples are `hifiasm`, `hicanu` and `flye`. If you want to start an assembly in one of those subdirectories. The scripts (not defined yet, for now bash scripts but those will be migrated into proper nextflow pipelines) should create another layer sub directories `run_1`, `run_2`, etc. in order to descrimnate different runs e.g. hifiasm with PacBio reads, hifiasm with PacBio reads + HiC reads, or even  hifiasm with PacBio reads + HiC reads + Ultr-long ONT reads. 

### `/rawdata`

Contains all the raw data (preferably in a compressed form). All files should be write-protected right after creation. All those files should usually be linked from the sequencing storage project 

### `/rawdata/10x`

The raw 10x data in gzipped FAST/A format (`.fastq.gz`).

### `/rawdata/bionano`

The raw bionano data in gzipped bnx format (`.bnx.gz`).

### `/rawdata/ont`

The raw Oxford Nanopore data `.fast5.gz` format.

### `/rawdata/pacbio`

The raw PacBio data in compressed `.bam` format. The files must be separated
according to the type of sequencing.

For CLR (lofi) PacBio data, this should be the .bam, .pbi and .sts.xml files

### `/data`

This folder contains preprocessed data. This might include the CCS counter-part
to the HiFi reads, the base-called FAST/A files for Oxford Nanopore reads and
the like. Files in this directory should be relevant to more than just one
pipeline.

### `/scripts`

This folder contains all executable scripts used in this project. Dependencies
of these scripts should be publicly available and their used version should be
documented exactly. **THIS NEEDS TO BE FILLED WITH SCRIPTS AND PIPELINES THAT COVER ALL AIMS FOR THE DIFFERENT SEQUENCING AND ASSEMBLY INITIATIVES**

### `/reports`

All the pipelines in the scripts directories have to include a part to collect QC metrics, images, program arguments and versions used, runtime stats etc. which will be presented in the reports directory 

### `/results`

A save place where to store the final assemblies, annotation tracks (etc?). So that we can savely remove all intermediate files fron the assembly directories.

### `/status`

**STILL NEEDS TO BE DEFINED** This folder should include empty files which describe the current status of the project. Potential key words could be:
 
- `HIFI_REQUIRED` project will get PacBio HiFi data 
- `HIC_REQUIRED`  project will get Illumina HiC data 
- `HIC_QC_DONE`   HiC QC successfully done
- `HIC_QC_FAILED` HiC QC done but failed 
- `ASSEMBLY_DONE` assembly done and frozen
- `WAITING_CUSTOMER` waiting for customer feedback
- `FINISHED`      Project is finished

... and potentially many more. Those keywords can then be used and visualized on the github repo, but might also be used to trigger certain scripts via cron jobs, which e.g. feed other git repos to keep track of all projects. 
