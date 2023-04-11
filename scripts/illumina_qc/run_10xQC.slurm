#!/bin/bash
#SBATCH -J {{PROJECT_ID}}_10xQC
#SBATCH -p batch
#SBATCH -c 8 #cores
#SBATCH -n 1 #nodes
#SBATCH --time=24:00:00

source activate multiqc

mkdir -p ../../QC/10x/fastqc
mkdir -p ../../QC/10x/fastp
mkdir -p ../../QC/10x/trim_galore
mkdir -p ../../QC/10x/seqkit_stats 

for f in ../../data/10x/*R1_001.fastq.gz;do
	fastqc $f ${f//R1_001.fastq.gz}R2_001.fastq.gz -t 8 -o ../../QC/10x/fastqc

	fastp -w 8 -i $f -I ${f//R1_001.fastq.gz}R2_001.fastq.gz -o ../../QC/10x/fastp/$(basename $f) -O ../../QC/10x/fastp/$(basename ${f//R1_001.fastq.gz})R2_001.fastq.gz -h ../../QC/10x/fastp/$(basename ${f//R1_001.fastq.gz})fasp.html -j ../../QC/10x/fastp/$(basename ${f//R1_001.fastq.gz})fastp.json

	trim_galore -j 8 --paired $f ${f//R1_001.fastq.gz}R2_001.fastq.gz -o ../../QC/10x/trim_galore
	
	/projects/dazzler/pippel/prog/bin/seqkit stats -a $f > ../../QC/10x/seqkit_stats/$(basename ${f//R1.fastq.gz})R1.seqkit.stats.txt
    /projects/dazzler/pippel/prog/bin/seqkit stats -a ${f//R1.fastq.gz}R2.fastq.gz > ../../QC/10x/seqkit_stats/$(basename ${f//R1.fastq.gz})R2.seqkit.stats.txt
done

cd ../../QC/10x

multiqc . 

git add multiqc_report.html
git commit -m "Added multiqc 10x report"
git push origin master

