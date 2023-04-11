### MARVEL PATH
MARVEL_SOURCE_PATH="/projects/dazzler/pippel/prog/MARVEL/DAMAR_OLD"
MARVEL_PATH="/projects/dazzler/pippel/prog/MARVEL/DAMAR_OLD-build/DAmar_TRACE_XOVR_125"

### DZZLER PATH
DAZZLER_SOURCE_PATH="/projects/dazzler/pippel/prog/dazzlerGIT"
DAZZLER_PATH="/projects/dazzler/pippel/prog/dazzlerGIT/TRACE_XOVR_125"

### slurm scripts path
SUBMIT_SCRIPTS_PATH="${MARVEL_PATH}/scripts"

############################## tools for pacbio arrow correction 
CONDA_BASE_ENV="source /projects/dazzler/pippel/prog/miniconda3/bin/activate base"
############################## tools HiC HiGlass pipleine, bwa, samtools, pairstools, cooler, ..;
CONDA_HIC_ENV="source /projects/dazzler/pippel/prog/miniconda3/bin/activate hic"
############################## activate purgehaplotigs environment if requires
CONDA_PURGEHAPLOTIGS_ENV="source /projects/dazzler/pippel/prog/miniconda3/bin/activate purge_haplotigs_env"
############################## tools for whatshap phasing
CONDA_WHATSHAP_ENV="source /projects/dazzler/pippel/prog/miniconda3/bin/activate whatshap"

### ENVIRONMENT VARIABLES 
export PATH=${MARVEL_PATH}/bin:${MARVEL_PATH}/scripts:$PATH
export PYTHONPATH=${MARVEL_PATH}/lib.python:$PYTHONPATH
export SCAFF10X_PATH="/projects/dazzler/pippel/prog/scaffolding/Scaff10X_git/src"
export BIONANO_PATH="/projects/dazzler/pippel/prog/bionano/Solve3.3_10252018"
export SALSA_PATH="/projects/dazzler/pippel/prog/scaffolding/SALSA"
export QUAST_PATH="/projects/dazzler/pippel/prog/quast/"
export JUICER_PATH="/projects/dazzler/pippel/prog/scaffolding/juicer"
export JUICER_TOOLS_PATH="/projects/dazzler/pippel/prog/scaffolding/juicer_tools.1.9.8_jcuda.0.8.jar"
export THREEDDNA_PATH="/projects/dazzler/pippel/prog/scaffolding/3d-dna/"
export LONGRANGER_PATH="/projects/dazzler/pippel/prog/longranger-2.2.2"
export SUPERNOVA_PATH="/projects/dazzler/pippel/prog/supernova-2.1.1"
export ARKS_PATH="/projects/dazzler/pippel/prog/scaffolding/arks-build/bin"
export TIGMINT_PATH="/projects/dazzler/pippel/prog/scaffolding/tigmint/bin"
export LINKS_PATH="/projects/dazzler/pippel/prog/scaffolding/links_v1.8.6/"
export JELLYFISH_PATH="/projects/dazzler/pippel/prog/Jellyfish/jellyfish-2.2.10/bin/"
export GENOMESCOPE_PATH="/projects/dazzler/pippel/prog/genomescope/"
export GATK_PATH="/projects/dazzler/pippel/prog/gatk-4.0.3.0/gatk-package-4.0.3.0-local.jar"
export BCFTOOLS_PATH="/projects/dazzler/pippel/prog/bcftools"
export SEQKIT_PATH="/projects/dazzler/pippel/prog/bin/seqkit"
export TOM_SCRIPTS="/projects/dazzlerAssembly/asm_{{PROJECT_ID}}/scripts"

########################################################
# Edit here
########################################################

## general information
PROJECT_ID={{PROJECT_ID}}1
GSIZE={{G_SIZE}}
SLURM_PARTITION=batch

## general settings raw read data bases  
RAW_DB=asm_{{PROJECT_ID}}_Z
RAW_DAZZ_DB=asm_{{PROJECT_ID}}_Z
RAW_COV=60

################# define marvel phases and their steps that should be done 

TENX_PATH="/projects/dazzlerAssembly/asm_{{PROJECT_ID}}/processed-data/10x/"
RAW_QC_LONGRANGERBASIC_PATH="/projects/dazzlerAssembly/asm_{{PROJECT_ID}}/processed-data/10x/LongRanger/10x_{{PROJECT_ID}}1_longrangerBasic/outs/barcoded.fastq.gz"
QC_DATA_DIR="/projects/dazzlerAssembly/asm_{{PROJECT_ID}}/processed-data/10x/GenomeScope"


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> phase -2 - data QC and statistics and format conversion <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#type-0 [10x - prepare] 						[1-3]: 01_longrangerBasic, 02_longrangerToScaff10Xinput, 03_bxcheck
#type-1 [10x - de novo] 						[1-1]: 01_supernova
#type-2 [10x|HiC - kmer-Gsize estimate] 				[1-2]: 01_genomescope
#type-3 [allData - MASH CONTAMINATION SCREEN] 				[1-5]: 01_mashPrepare, 02_mashSketch, 03_mashCombine, 04_mashPlot, 05_mashScreen
#type-4 [10x - QV]   							[1-4]: 01_QVprepareInput, 02_QVlongrangerAlign, 03_QVcoverage, 04QVqv

RAW_QC_TYPE=2
RAW_QC_SUBMIT_SCRIPTS_FROM=1
RAW_QC_SUBMIT_SCRIPTS_TO=1

# ***************************************************************** runtime parameter for slurm settings:  threads, mem, time ***************************************************************

### default parameter for 24-core nodes  #####
THREADS_DEFAULT=1
MEM_DEFAULT=64000
TIME_DEFAULT=24:00:00

##### DBdust  #####
THREADS_DBdust=1
MEM_DBdust=16720
TIME_DBdust=00:30:00
STEPSIZE_DBdust=5

#### Juicer/3d-dna pipeline
THREADS_juicer=24
if [[ "${SLURM_PARTITION}" == "gpu" ]]
then 
	THREADS_juicer=38
elif [[ "${SLURM_PARTITION}" == "bigmem" ]]
then 
	THREADS_juicer=48
fi

THREADS_mashPlot=1
MEM_mashPlot=64000
TIME_mashPlot=24:00:00

THREADS_mashScreen=${THREADS_juicer}
MEM_mashScreen=64000
TIME_mashScreen=24:00:00

THREADS_LongrangerLongrangerWgs=4
MEM_LongrangerLongrangerWgs=$((${THREADS_juicer}*8192))
TIME_LongrangerLongrangerWgs=240:00:00
PARTITION_LongrangerLongrangerWgs=gpu

THREADS_FBfreebayes=1
MEM_FBfreebayes=32768
TIME_FBfreebayes=24:00:00

THREADS_supernova=${THREADS_juicer}
MEM_supernova=$((${THREADS_juicer}*8192))
TIME_supernova=24:00:00
