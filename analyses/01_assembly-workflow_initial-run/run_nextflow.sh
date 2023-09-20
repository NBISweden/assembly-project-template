#! /usr/bin/env bash

NXF_SCRIPT="Earth-Biogenome-Project-pilot/main.nf"
WORKDIR='/proj/nais/nobackup/nxf-work'

nextflow run -resume \
    --input assembly_parameters.yml \
    -profile uppmax,execution_report \
    -work-dir "$WORKDIR" \
    "$NXF_SCRIPT"

# Use `nextflow log` to see the time and state of the last nextflow executions.
