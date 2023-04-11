#!/bin/bash
#SBATCH -J {{PROJECT_ID}}_DLE1
#SBATCH -p gpu 
#SBATCH -c 1 # Number of cores 
#SBATCH -n 1
#SBATCH --mem=84720
#SBATCH --time=240:00:00

beg=$(date +%s)
echo "beg $beg"

REFALIGNER_DIR=/projects/dazzler/pippel/prog/bionano/Solve3.5.1_01142020/RefAligner/1.0
PIPELINE_DIR=/projects/dazzler/pippel/prog/bionano/Solve3.5.1_01142020/Pipeline/1.0
SCRIPT_DIR=/projects/dazzler/pippel/prog/bionano/Solve3.5.1_01142020/HybridScaffold/1.0/scripts

export PATH=${PIPELINE_DIR}:${REFALIGNER_DIR}:${SCRIPT_DIR}:$PATH
export SGE_ROOT=/sw/apps/slurm-drmaa/current
export DRMAA_LIBRARY_PATH=/sw/lib/libdrmaa.so

${REFALIGNER_DIR}/RefAligner -if bnx_filePaths.txt -merge -o ../../data/bionano/{{PROJECT_ID}}_MERGE -bnx -stdout -stderr
