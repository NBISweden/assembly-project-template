#!/bin/bash
#SBATCH -J asm_{{PROJECT_ID}}_hicQC
#SBATCH -p batch
#SBATCH -c 8 #cores
#SBATCH -n 1 #nodes
#SBATCH --time=24:00:00

source activate multiqc

mkdir -p ../../QC/hic/fastqc
mkdir -p ../../QC/hic/fastp
mkdir -p ../../QC/hic/trim_galore
mkdir -p ../../QC/hic/seqkit_stats 

for f in ../../data/hic/*R1.fastq.gz;do
	fastqc $f ${f//R1.fastq.gz}R2.fastq.gz -t 8 -o ../../QC/hic/fastqc

	fastp -w 8 -i $f -I ${f//R1.fastq.gz}R2.fastq.gz -o ../../QC/hic/fastp/$(basename $f) -O ../../QC/hic/fastp/$(basename ${f//R1.fastq.gz})R2.fastq.gz -h ../../QC/hic/fastp/$(basename ${f//R1.fastq.gz})fastp.html -j ../../QC/hic/fastp/$(basename ${f//R1.fastq.gz})fastp.json

	trim_galore -j 8 --paired $f ${f//R1.fastq.gz}R2.fastq.gz -o ../../QC/hic/trim_galore

	/projects/dazzler/pippel/prog/bin/seqkit stats -a $f > ../../QC/hic/seqkit_stats/$(basename ${f//R1.fastq.gz})R1.seqkit.stats.txt
    /projects/dazzler/pippel/prog/bin/seqkit stats -a ${f//R1.fastq.gz}R2.fastq.gz > ../../QC/hic/seqkit_stats/$(basename ${f//R1.fastq.gz})R2.seqkit.stats.txt
done

cd ../../QC/hic

multiqc .

git add multiqc_report.html
git commit -m "Added multiqc hic report"
git push origin master
