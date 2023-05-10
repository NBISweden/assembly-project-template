#!/bin/bash 

# exit when any command fails
set -e

# WE WILL TELL EXACTLY WHAT WE WANT TO PASS TO SLURM
# I AM USING FLAGS BECAUSE I FEEL IT IS MORE EXPLICIT WHAT THEY ARE
while getopts i:r:t:p:m:b:e: flag
do
    case "${flag}" in
        i) projectID=${OPTARG};;
        r) runID=${OPTARG};;
        t) runTIME=${OPTARG};;
        p) runPROJECT=${OPTARG};;
        m) runMEMORY=${OPTARG};;
        b) FROM=${OPTARG};;
        e) TO=${OPTARG};;
    esac
done

# SPIT OUT THE USAGE IF RAN WITHOUT PARAMETERS
if [ $# -eq 0 ]; then
    >&2 echo "script usage: $(basename $0) [-i project ID] [-r run ID] [-r run time] [-p run project] [-m run memory] [-b INT first step to take] [-e INT last step to take]"
    >&2 echo "Write the parameters in a way compatible with SLURM"
    exit 1
fi

# MAKE SURE FROM AND TO MAKES SENSE
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

# LET'S MAKE PEOPLE USE THE GOOD ONES
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


FULL_SCRIPTS_PATH=$(readlink -f $(basename $0)) 
DIR_SCRIPTS_PATH=$(dirname ${FULL_SCRIPTS_PATH})
SCRIPTS_FILE=$(basename $0)

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

# CREATE THE SBATCH SCRIPT

# NAME PER RUN
output_script="${projectID}_run_${runID}.sbatch"
# CREATE THE FILE
touch $output_script

# CREATE THE SBATCH HEADER WITH THE PARAMETERS
sbatch_header=$(echo -e "#!/bin/bash\n#SBATCH -J ${projectID}\n#SBATCH -p core\n#SBATCH -c 20 #cores\n#SBATCH -n 1 #nodes\n#SBATCH --time=${runTIME}\n#SBATCH -A ${runPROJECT}\n#SBATCH --mem=${runMEMORY}\n#SBATCH -e hifiasm.%A.err\n#SBATCH -o hifiasm.%A.out")

# ADDING THIS TO THE FILE
printf "$sbatch_header" >> $output_script

# ADDING TWO EMPTY LINES
x=$'\n\n'
printf '%s\n' "$x" >> $output_script

# THE REST OF THE SCRIPT
sbatch_script=$(cat <<-'EOF'

# both tools: hifiasm and gfastats need to be accessible in the PATH variable (for now)

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

for l in $(seq 3 -1 0)
do
  hifiasm -l${l} -o {{PROJECT_ID}} -t 20  *.{fq,fastq,fq.gz,fastq.gz}

  if [[ $l -gt 0 ]]
  then 
    awk '/^S/{print ">"$2"\n"$3}' {{PROJECT_ID}}.bp.p_ctg.gfa | fold > {{PROJECT_ID}}.bp.p_ctg_l${l}.fasta
    awk '/^S/{print ">"$2"\n"$3}' {{PROJECT_ID}}.bp.hap1.p_ctg.gfa | fold > {{PROJECT_ID}}.bp.hap1_l${l}.fasta
    awk '/^S/{print ">"$2"\n"$3}' {{PROJECT_ID}}.bp.hap2.p_ctg.gfa | fold > {{PROJECT_ID}}.bp.hap2_l${l}.fasta

    gfastats {{PROJECT_ID}}.bp.p_ctg_l${l}.fasta > {{PROJECT_ID}}.bp.p_ctg_l${l}.stats.txt &
    gfastats {{PROJECT_ID}}.bp.hap1_l${l}.fasta > {{PROJECT_ID}}.bp.hap1_l${l}.stats.txt &
    gfastats {{PROJECT_ID}}.bp.hap2_l${l}.fasta > {{PROJECT_ID}}.bp.hap2_l${l}.stats.txt &

  else
    awk '/^S/{print ">"$2"\n"$3}' {{PROJECT_ID}}.bp.hap1.p_ctg.gfa | fold > {{PROJECT_ID}}.bp.hap1_l${l}.fasta
    awk '/^S/{print ">"$2"\n"$3}' {{PROJECT_ID}}.bp.hap2.p_ctg.gfa | fold > {{PROJECT_ID}}.bp.hap2_l${l}.fasta 

    gfastats {{PROJECT_ID}}.bp.hap1_l${l}.fasta > {{PROJECT_ID}}.bp.hap1_l${l}.stats.txt
    gfastats {{PROJECT_ID}}.bp.hap2_l${l}.fasta > {{PROJECT_ID}}.bp.hap2_l${l}.stats.txt

  fi 
done

## start documentation part 
echo "hifiasm $(hifiasm --version)" > {{PROJECT_ID}}_hifiasm.%A.version 
echo "gfastats $(gfastats --version | head -n 1)" >> {{PROJECT_ID}}_hifiasm.%A.version 

EOF
)

# ADDING IT TO THE SCRIPT FILE
echo "$sbatch_script" >> $output_script

# Submit HiFiasm job to the compute cluster
if [[ $FROM -le 1 && $TO -ge 1 ]]
then
    if [[ ! -d ${DIR_SCRIPTS_PATH}/../../../assembly/hifiasm/run_${runID} ]]
    then 
        (>&2 echo -e "[ERROR]: Missing run directory ${DIR_SCRIPTS_PATH}/../../../assembly/hifiasm/run_${runID}! Have you started the pipeline from step 0 or 1?")
        exit 1
    fi 

    cp ${DIR_SCRIPTS_PATH}/$output_script ${DIR_SCRIPTS_PATH}/../../../assembly/hifiasm/run_${runID}

    pushd ${DIR_SCRIPTS_PATH}/../../../assembly/hifiasm/run_${runID}
    pwd
    jid1=$(sbatch $output_script)
    echo "Step 1 HiFiasm submitted: ${jid1##* }"
    popd 
else 
    (>&2 echo -e "[INFO] Skip step 1 HiFiasm!")
fi 

