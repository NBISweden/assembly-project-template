#!/bin/bash
#SBATCH -J asm_fAntPal_DLE1
#SBATCH -p gpu 
#SBATCH -c 1 # Number of cores 
#SBATCH -n 1
#SBATCH -o /projects/dazzlerAssembly/asm_fAntPal/assembly/bionano/log_DLE1/asm_fAntPal_BionanoDLE1_%A.out # Standard output 
#SBATCH -e /projects/dazzlerAssembly/asm_fAntPal/assembly/bionano/log_DLE1/asm_fAntPal_BionanoDLE1_%A.err # Standard error
#SBATCH --mem=84720
#SBATCH --time=240:00:00

beg=$(date +%s)
echo "beg $beg"

#export PATH=/projects/dazzler/pippel/prog/bionano/Solve3.1_08232017/Pipeline/08212017:/projects/dazzler/pippel/prog/bionano/Solve3.1_08232017/HybridScaffold/08212017/scripts/:/projects/dazzler/pippel/prog/bionano/Solve3.1_08232017/RefAligner/6700.6902rel/avx:$PATH 
#export PATH=/projects/dazzler/pippel/prog/bionano/Solve3.2.1_04122018/Pipeline/04122018/:/projects/dazzler/pippel/prog/bionano/Solve3.2.1_04122018/HybridScaffold/04122018/scripts/:/projects/dazzler/pippel/prog/bionano/Solve3.2.1_04122018/RefAligner/7437.7523rel/avx/:$PATH
#export PATH=/projects/dazzler/pippel/prog/bionano/Solve3.2.2_08222018/Pipeline/08222018/:/projects/dazzler/pippel/prog/bionano/Solve3.2.2_08222018/HybridScaffold/08222018/scripts:/projects/dazzler/pippel/prog/bionano/Solve3.2.2_08222018/RefAligner/7782.7865rel/avx:$PATH 


REFALIGNER_DIR=/projects/dazzler/pippel/prog/bionano/Solve3.5.1_01142020/RefAligner/1.0
PIPELINE_DIR=/projects/dazzler/pippel/prog/bionano/Solve3.5.1_01142020/Pipeline/1.0
SCRIPT_DIR=/projects/dazzler/pippel/prog/bionano/Solve3.5.1_01142020/HybridScaffold/1.0/scripts

export PATH=${PIPELINE_DIR}:${REFALIGNER_DIR}:${SCRIPT_DIR}:$PATH
export SGE_ROOT=/sw/apps/slurm-drmaa/current 
export DRMAA_LIBRARY_PATH=/sw/lib/libdrmaa.so 

BNX=/projects/dazzlerAssembly/asm_fAntPal/data/bionano/{{BNX_FILE}}
ARG=${REFALIGNER_DIR}/optArguments_nonhaplotype_DLE1_saphyr.xml
CFILE=clusterArguments_customGPU.xml
REF=fAnaAna_polish_DLE1_0kb_0labels.cmap

${REFALIGNER_DIR}/RefAligner -version
python2.7 ${PIPELINE_DIR}/pipelineCL.py -v
echo "python2.7 ${PIPELINE_DIR}/pipelineCL.py -T 20 -j 20  -i 7 -b ${BNX} -l asm_fAntPal_DLE1_assembly_v33_default -t ${REFALIGNER_DIR}/avx -a ${ARG} -e asm_fAntPal -C ${CFILE} -V 0 -c 1 -p 3 -N 4 -F 1 -W 0.75 -r ${REF}"
python2.7 ${PIPELINE_DIR}/pipelineCL.py -T 20 -j 20  -i 7 -b ${BNX} -l asm_fAntPal_DLE1_assembly_v33_default -t ${REFALIGNER_DIR}/avx -a ${ARG} -e asm_fAntPal  -C ${CFILE} -V 0 -c 1 -p 3 -N 4 -F 1 -W 0.75 -r ${REF}

end=$(date +%s)
echo "end $end"
echo "run time: $((${end}-${beg}))"
