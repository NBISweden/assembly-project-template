#! /usr/bin/env bash

set -euo pipefail

function get_cluster_name {
    if command -v sacctmgr >/dev/null 2>&1; then
        # Only return cluster names we're catering for
        sacctmgr show cluster -P -n \
        | cut -f1 -d'|' \
        | grep "rackham\|dardel\|nac"
    fi
}

function run_nextflow {
    PROFILE="${PROFILE:-$1}"                    # Profile to use (values: uppmax, dardel, nac)
    STORAGEALLOC="$2"                           # NAISS storage allocation (path)
    WORKDIR="${PWD/analyses/nobackup}/nxf-work" # Nextflow work directory
    RESULTS="${PWD/analyses/data/outputs}"      # Path to store results from Nextflow

    # Path to Nextflow script. Pulls from Github
    WORKFLOW="${WORKFLOW:-NBISweden/Earth-Biogenome-Project-pilot}"
    # Workflow version or branch to use (default: main)
    BRANCH="${BRANCH:-main}"

    # Set common path to store all Singularity containers
    export NXF_SINGULARITY_CACHEDIR="${STORAGEALLOC}/nobackup/ebp-singularity-cache"

    # Activate shared Nextflow environment
    set +u
    eval "$(conda shell.bash hook)"
    conda activate "${STORAGEALLOC}/conda/nextflow-env"
    set -u

    # Clean results folder if last run resulted in error
    if [ "$( nextflow log | awk -F $'\t' '{ last=$4 } END { print last }' )" == "ERR" ]; then
        echo "WARN: Cleaning results folder due to previous error" >&2
        rm -rf "$RESULTS"
    fi

    # Use latest version of branch if not using local file
    REMOTE_OPTS=""
    if ! test -f "$WORKFLOW"; then
        REMOTE_OPTS="-r $BRANCH -latest"
    fi

    # Run nextflow 
    nextflow run "$WORKFLOW" \
        $REMOTE_OPTS \
        -profile "$PROFILE" \
        -work-dir "$WORKDIR" \
        -resume \
        -ansi-log false \
        -params-file workflow_parameters.yml \
        --cache "${STORAGEALLOC}/nobackup/database-cache" \
        --outdir "$RESULTS"

    # Clean up Nextflow cache to remove unused files
    nextflow clean -f -before "$( nextflow log -q | tail -n 1 )"
    # Clean up empty work directories
    find "$WORKDIR" -type d -empty -delete
    # Use `nextflow log` to see the time and state of the last nextflow executions.

}

# Detect cluster name ( rackham, dardel )
cluster=$( get_cluster_name )
echo "Running on HPC=$cluster."

# Run Nextflow with appropriate settings
if [ "$cluster" == "rackham" ]; then
    run_nextflow uppmax /proj/snic2021-6-194
elif [ "$cluster" == "dardel" ]; then
    module load PDC apptainer
    export APPTAINER_CACHEDIR=$PDC_TMP/apptainer/cache
    export SINGULARITY_CACHEDIR=$PDC_TMP/singularity/cache
    run_nextflow dardel /cfs/klemming/projects/snic/snic2021-6-194
elif [ "$cluster" == "nac" ]; then
    module load Singularity
    run_nextflow nac /projects/earth_biogenome_project/
else 
    echo "Error: unrecognised cluster '$cluster'." >&2
    exit 1
fi

# Print git status to remind users to check in untracked/updated files
git status
