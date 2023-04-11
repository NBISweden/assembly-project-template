#!/bin/bash
#SBATCH -J asm_{{PROJECT_ID}}_DLE1
#SBATCH -p gpu 
#SBATCH -c 1 # Number of cores 
#SBATCH -n 1
#SBATCH -o /projects/dazzlerAssembly/asm_{{PROJECT_ID}}/assembly/bionano/log_DLE1/asm_{{PROJECT_ID}}BionanoHybridScaffoldDLE1_%A.out # Standard output 
#SBATCH -e /projects/dazzlerAssembly/asm_{{PROJECT_ID}}/assembly/bionano/log_DLE1/asm_{{PROJECT_ID}}BionanoHybridScaffoldDLE1_%A.err # Standard error
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

BNX=/projects/dazzlerAssembly/asm_{{PROJECT_ID}}/data/bionano/L47881_RawMolecules.bnx
ARG=/projects/dazzlerAssembly/asm_{{PROJECT_ID}}/scripts/bionano/hybridScaffold_DLE1_config.xml
CFILE=/projects/dazzlerAssembly/asm_{{PROJECT_ID}}/scripts/bionano/clusterArguments_customGPU.xml
#REF={{REF_CMAP}}

input_fasta=../../assembly/Scaff10X/cns_p_ctg_purgedScaff10x.fa
input_cmap=../../assembly/bionano/asm_{{PROJECT_ID}}_DLE1_assembly_v351_noES/keep_files/contigs/{{CMAP_ID}}_REFINEFINAL1.cmap

cd ../../assembly/bionano/

perl5.16.3 /projects/dazzler/pippel/prog/bionano/Solve3.5.1_01142020/HybridScaffold/1.0/hybridScaffold.pl -n $input_fasta -b $input_cmap -c $ARG -r $REFALIGNER_DIR/RefAligner -B 2 -N 2 -f -o test_hybridScaffold

end=$(date +%s)
echo "end $end"
echo "run time: $((${end}-${beg}))"

mv ../../status/BionanoHybridScaffolds.todo ../../status/BionanoHybridScaffolds.done
