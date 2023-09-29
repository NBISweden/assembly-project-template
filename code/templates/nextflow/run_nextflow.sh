#! /usr/bin/env bash

# NAISS compute allocation
COMPUTEALLOC='/proj/snic2021-5-291'
# NAISS storage allocation
STORAGEALLOC='/proj/snic2021-6-194'
# Nextflow work directory (e.g. /proj/snic2021-6-194/BGE-species/analyses/01_.../ -> /proj/snic2021-6-194/nobackup/BGE-species/analyses/01_.../nxf-work)
WORKDIR="${PWD/$STORAGEALLOC/"$STORAGEALLOC/nobackup"}/nxf-work"
# Path to store results from Nextflow
RESULTS="${PWD/analyses/"data/intermediates"}"
# Path to Nextflow script. Pulls from Github
NXF_SCRIPT="NBISweden/Earth-Biogenome-Project-pilot/main.nf"
# Set common path to store all Singularity containers
export NXF_SINGULARITY_CACHEDIR="${STORAGEALLOC}/nobackup/ebp-singularity-cache"

# Activate shared Nextflow environment
eval "$(conda shell.bash hook)"
conda activate "${COMPUTEALLOC}/conda/nextflow-env"

# Clean results folder

# Run Nextflow
nextflow run -resume -ansi-log false \
    --input assembly_parameters.yml \
    --outdir "$RESULTS" \
    -profile uppmax,execution_report \
    -work-dir "$WORKDIR" \
    "$NXF_SCRIPT"

# Clean up Nextflow cache to remove unused files
nextflow clean -f -before $( nextflow log -q | tail -n 1 )
# Use `nextflow log` to see the time and state of the last nextflow executions.
