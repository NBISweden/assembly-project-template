#!/bin/bash 

# default hifiasm pipeline 
# steps:
# 0. create new run directory and link data 
# 1. run hifiasm - including all pruging options l={0,1,2,3}
# 2. run busco on all hifiasm fasta files 
# 3. run purge_dups on all hifiasm fasta files 
# 4. run busco on purged fasta files
# 5. create summary markdown files and update git repo 

# exit when any command fails
set -e

function usage()
{
    (>&2 echo -e "$0 runID [FROM_STEP TO_STEP]\n")
    (>&2 echo -e "pipeline to run hifiasm in default mode + busco + purge_dupse + busco\n")
    (>&2 echo -e "runId should be an int, the script will create a new dir run_<runID> in assembly/hifiasm")
    (>&2 echo -e "")
    (>&2 echo -e "steps: TODO")
}

if [[ $# -lt 1 ]]
then
    usage;
    exit 1;
fi

## run pipeline from - to, in case of fail and restart 
FROM=0
TO=5

runID=$1; 
re='^[0-9]+$'
if ! [[ $runID =~ $re ]] ;
then
    (>&2 echo -e "[ERROR]: runID ${runID} must be a number")
    usage
    exit 1
fi

if [[ "x$2" != "x" ]]
then
    FROM=$2
fi

if [[ "x$3" != "x" ]]
then
    TO=$3
fi

re='^[0-9]+$'
if ! [[ $FROM =~ $re ]] ;
then
    (>&2 echo -e "[ERROR]: FROM_STEP ${FROM} must be a number")
    usage
    exit 1
fi
if ! [[ $TO =~ $re ]] ;
then
    (>&2 echo -e "[ERROR]: TO_STEP ${TO} must be a number")
    usage
    exit 1
fi

if [[ $FROM -gt $TO ]] ;
then
    (>&2 echo -e "[ERROR]: FROM_STEP ${FROM} must be smaller or equal to TO_STEP ${TO}")
    usage
    exit 1
fi

if [[ $FROM -lt 0 ]] ;
then
    (>&2 echo -e "[ERROR]: FROM_STEP ${FROM} must be in [1,5]")
    usage
    exit 1
fi

if [[ $TO -gt 5 ]] ;
then
    (>&2 echo -e "[ERROR]: TO_STEP ${TO} must be in [1,5]")
    usage
    exit 1
fi

myShell=$(basename $SHELL)
if [[ "${myShell}" ==  "bash" ]]
then 
    shopt -s nullglob extglob
elif [[ "${myShell}" ==  "zsh" ]]
then 
    setopt NULL_GLOB EXTENDED_GLOB
else 
    (>&2 echo -e "[ERROR]: Your shell "${myShell}" is not supported. Please use zsh or bash!") 
    exit 1
fi 


FULL_SCRIPTS_PATH=$(readlink -f $0) 
DIR_SCRIPTS_PATH=$(dirname ${FULL_SCRIPTS_PATH})
SCRIPTS_FILE=$(basename ${FULL_SCRIPTS_PATH})

# 1. try to create a new run directory and link Hifi data into it
if [[ $FROM -eq 0 ]]
then
    # A. sanity check - directory should not be present when starting from step 0
    if [[ -d ${DIR_SCRIPTS_PATH}/../../../assembly/hifiasm/run_${runID} ]]
    then 
        (>&2 echo -e "[ERROR]: run directory ${DIR_SCRIPTS_PATH}/../../../assembly/hifiasm/run_${runID} already present!")
        (>&2 echo -e "         Either start the script from step 2, use another run dir, or remove the old run dir first!")
        exit 1        
    fi 

    # B. check if any fastq files are present in the corresponding data/pacbio/hifi folder 
    fastq_files=(${DIR_SCRIPTS_PATH}/../../../data/pacbio/hifi/*.{fq,fastq,fq.gz,fastq.gz})
    
    if [[ ${#fastq_files} -eq 0 ]]
    then 
        (>&2 echo -e "[ERROR]: Could not find any fastq file in following dir ${DIR_SCRIPTS_PATH}/../../../data/pacbio/hifi/.") 
        exit 1
    fi 

    # C. create run dir and link all HiFi files into it
    mkdir -p ${DIR_SCRIPTS_PATH}/../../../assembly/hifiasm/run_${runID} ||  (>&2 echo -e "[ERROR]: Could not create a new run directory ${DIR_SCRIPTS_PATH}/../../../assembly/hifiasm/run_${runID}" && exit 1)

    c=1;
    for i in ${fastq_files[@]}
    do 
        f=$(basename $i)
        f_ext=${f#*.}
        ln -s -r ${i} ${DIR_SCRIPTS_PATH}/../../../assembly/hifiasm/run_${runID}/HIFI_${c}.${f_ext}
        c=$((c+1))
    done 

    (>&2 echo "Step 0 HiFiasm - setup run dir and Link files into it")
else 
    (>&2 echo -e "[INFO] Skip step 0 HiFiasm!")
fi 

# Submit HiFiasm job to the compute cluster
if [[ $FROM -le 1 && $TO -ge 1 ]]
then
    if [[ ! -d ${DIR_SCRIPTS_PATH}/../../../assembly/hifiasm/run_${runID} ]]
    then 
        (>&2 echo -e "[ERROR]: Missing run directory ${DIR_SCRIPTS_PATH}/../../../assembly/hifiasm/run_${runID}! Have you started the pipeline from step 0?")
        exit 1
    fi 

    cp ${DIR_SCRIPTS_PATH}/hifiasm_default.sbatch ${DIR_SCRIPTS_PATH}/../../../assembly/hifiasm/run_${runID}

    pushd ${DIR_SCRIPTS_PATH}/../../../assembly/hifiasm/run_${runID}
    pwd
    jid1=$(sbatch hifiasm_default.sbatch)
    echo "Step 1 HiFiasm submitted: ${jid1##* }"
    popd 
else 
    (>&2 echo -e "[INFO] Skip step 1 HiFiasm!")
fi 
