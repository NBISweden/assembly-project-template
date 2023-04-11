# Assembly Project Template

This is a template for all assembly project. Please read the instructions below
on how to use it.


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

    {type}-{class#1}{genus#3}{species#3}[_{increment}]

The individual parts are:

- `{type}`:
    - `asm` for _de novo_ assemblies
    - `map` for reference guided/mapping-type projects.
- `{class#1}`: The first letter of the class of the sequenced indivdual,
  examples:
    - `f` for fish
    - `m` for mammals
    - `w` for worms
- `{genus#3}`: The first three letters of the indivdual's genus
- `{species#3}`: The first three letters of the indivdual's species
- `_{increment}`: Serial number to distinguish different projects concerning
  the same species. This is optional for `asm` projects and mandatory for `map`
  projects.

## Directory Structure Specification

The directory structure in the repository is as follows:

```
/
|-- assembly
|   |-- DAmar
|   |-- Falcon
|   `-- Flye
|-- rawdata
|   |-- 10x
|   |-- bionano
|   |-- hic
|   |-- ont
|   `-- pacbio
|       |-- hifi
|       |-- isoseq
|       `-- lofi
|-- data
|   |-- 10x
|   |-- bionano
|   |-- hic
|   |-- ont
|   `-- pacbio
|       |-- hifi
|       |-- isoseq
|       `-- lofi
|-- scripts
|   `--pacbio_stats
`-- QC
    `-- pacbio
        `-- lofi
            |-- coverage
            `-- read_stats
```

The contents of each directory are specified in the following.


### `/assembly`

There must be a folder for every assembly pipeline used in the project. Examples are `DAmar`, `Falcon` and `Flye`.

### `/rawdata`

Contains all the raw data (preferably in a compressed form). All files should be write-protected right after creation.

### `/rawdata/10x`

The raw 10x data in gzipped FAST/A format (`.fasta.gz`).

### `/rawdata/bionano`

The raw bionano data in gzipped FAST/A format (`.fasta.gz`).

### `/rawdata/ont`

The raw Oxford Nanopore data in gzipped `.fast5.gz` format.

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
documented exactly.
