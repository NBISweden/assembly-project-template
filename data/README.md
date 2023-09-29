# README

Data stored in these subfolders must not be tracked with Git (Use `git status`
to verify before running `git add`). The only parts that are intended to be
tracked are the top-level folder structure, README files, and data provenance scripts.

```
/data
    | - deliveries    (data deliveries moved from INBOX and made read-only)
    | - raw-data      (subfolders named after library-type, symlinked to files in deliveries, managed by a script for data integrity)
    | - intermediates (workflow/script outputs from exploratory phase)
    \ - finalized     (symlinked folders to `intermediates` marking assembly phase end-points)
```

## Deliveries

Move folders from `INBOX` to here, and make read-only (`chmod -R uga-w <delivery_folder>`). 
This folder should contain only data deliveries from sequencing centers.

## Raw data

Symlink files into subfolders using the translation table. Run the `update-link-data.sh` script
to maintain link integrity. Subfolder names should indicate the Sequencing platform and library type
e.g., `PacBio-Revio-WGS`, `Illumina-HiC-OmniC`, `Illumina-RNAseq`.

Additional files can be downloaded to subfolders named after data type, and should include a 
provenance script to refetch data.

```bash
#! /usr/bin/env bash

curl -O ftps://path/to/public/archive/file.fasta
```

## Intermediates

Store your analysis results in this folder that are relevant to evaluation.
Use a folder in `nobackup` to isolate files from a run.

## Finalized

These are symlinked folders linking to intermediate folders of results that should not change further.
