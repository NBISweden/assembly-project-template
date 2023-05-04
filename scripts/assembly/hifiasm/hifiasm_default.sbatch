#!/bin/bash
#SBATCH -J {{PROJECT_ID}}_hifiasm
#SBATCH -p core
#SBATCH -c 20 #cores
#SBATCH -n 1 #nodes
#SBATCH --time={{HIFIASM_SLURM_TIME}}
#SBATCH -A {{PROJECT_SLURM_ACCOUNT}} 
#SBATCH --mem={{HIFIASM_SLURM_MEM}}
#SBATCH -e hifiasm.%A.err 
#SBATCH -o hifiasm.%A.out

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

echo "for l in \$(seq 3 -1 0)
do
  hifiasm -l\${l} -o {{PROJECT_ID}} -t 20  *.fastq.gz

  if [[ \$l -gt 0 ]]
  then 
    awk '/^S/{print \">\"\$2\"\\n\"\$3}' {{PROJECT_ID}}.bp.p_ctg.gfa | fold > {{PROJECT_ID}}.bp.p_ctg_l\${l}.fasta
    awk '/^S/{print \">\"\$2\"\\n\"\$3}' {{PROJECT_ID}}.bp.hap1.p_ctg.gfa | fold > {{PROJECT_ID}}.bp.hap1_l\${l}.fasta
    awk '/^S/{print \">\"\$2\"\\n\"\$3}' {{PROJECT_ID}}.bp.hap2.p_ctg.gfa | fold > {{PROJECT_ID}}.bp.hap2_l\${l}.fasta

    gfastats {{PROJECT_ID}}.bp.p_ctg_l\${l}.fasta > {{PROJECT_ID}}.bp.p_ctg_l\${l}.stats.txt &
    gfastats {{PROJECT_ID}}.bp.hap1_l\${l}.fasta > {{PROJECT_ID}}.bp.hap1_l\${l}.stats.txt &
    gfastats {{PROJECT_ID}}.bp.hap2_l\${l}.fasta > {{PROJECT_ID}}.bp.hap2_l\${l}.stats.txt &

  else
    awk '/^S/{print \">\"\$2\"\\n\"\$3}' {{PROJECT_ID}}.bp.hap1.p_ctg.gfa | fold > {{PROJECT_ID}}.bp.hap1_l\${l}.fasta
    awk '/^S/{print \">\"\$2\"\\n\"\$3}' {{PROJECT_ID}}.bp.hap2.p_ctg.gfa | fold > {{PROJECT_ID}}.bp.hap2_l\${l}.fasta 

    gfastats {{PROJECT_ID}}.bp.hap1_l\${l}.fasta > {{PROJECT_ID}}.bp.hap1_l\${l}.stats.txt
    gfastats {{PROJECT_ID}}.bp.hap2_l\${l}.fasta > {{PROJECT_ID}}.bp.hap2_l\${l}.stats.txt

  fi 
done" >> {{PROJECT_ID}}_hifiasm.%A.cmds