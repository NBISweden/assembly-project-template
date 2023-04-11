#!/bin/bash pbdevEnv="source /projects/dazzler/pippel/prog/miniconda3/bin/activate pbbioconda-dev"
pbEnv="source /projects/dazzler/pippel/prog/miniconda3/bin/activate pbbioconda"
pbdevEnv="source /projects/dazzler/pippel/prog/miniconda3/bin/activate pbbioconda-dev"
DAZZLER_PATH="/projects/dazzler/pippel/prog/dazzlerGIT/TRACE_XOVR_125"

PROJECT_ID=asm_fAntPal
source /projects/dazzler/pippel/prog/miniconda3/bin/activate pbbioconda

for i in ../data/pacbio/hifi/*subreads.bam;do
	inFile=${i}
	outDir=../processed-data/pacbio/hifi
	outFilePrefix=$(basename ${i%.subreads.bam}).ccs
	
	if [ ! -f ${i}.pbi ];then
		pbindex ${i}
	fi

	# chunk data into N parts: 
	CHUNKS=200
	# threads per ccs job 
	THREAD=8
	# log level  TRACE, DEBUG, INFO, WARN, FATAL
	LOGLEVEL=INFO

	# MEM per job 
	mem=12G
	# job time limit
	tim=24:00:00
	# partition 
	partition="batch"
	# submit ccs jobs to the cluster 
	jid1=$(sbatch --array=1-${CHUNKS} -c ${THREAD} -n 1 -p ${partition} --mem=${mem} -e ${outDir}/"${outFilePrefix}".%A.%a.err -o "${outDir}"/"${outFilePrefix}".%A.%a.out --time=${tim} -J ccs --wrap="${pbdevEnv} && ccs ${inFile} ${outDir}/${outFilePrefix}.\${SLURM_ARRAY_TASK_ID}.bam --chunk \${SLURM_ARRAY_TASK_ID}/${CHUNKS} -j ${THREAD} --log-level ${LOGLEVEL} --log-file ${outDir}/${outFilePrefix}.\${SLURM_ARRAY_TASK_ID}.log --report-file ${outDir}/${outFilePrefix}.\${SLURM_ARRAY_TASK_ID}.report.txt")
	echo "submit job ${jid1##* }: ${pbdevEnv} && ccs ${inFile} ${outDir}/${outFilePrefix}.\${SLURM_ARRAY_TASK_ID}.bam --chunk \${SLURM_ARRAY_TASK_ID}/${CHUNKS} -j ${THREAD} --log-level ${LOGLEVEL} --log-file ${outDir}/${outFilePrefix}.\${SLURM_ARRAY_TASK_ID}.log --report-file ${outDir}/${outFilePrefix}.\${SLURM_ARRAY_TASK_ID}.report.txt"
	# submit merge job to the cluster 
	jid1=$(sbatch -c ${THREAD} -n 1 --dependency=afterok:"${jid1##* }" -J merge --mem=${mem} -p ${partition} --time=${tim} --wrap="${pbEnv} && /sw/bin/samtools merge -@${THREAD} -c ${outDir}/${outFilePrefix}.bam ${outDir}/${outFilePrefix}.*.bam")
	echo "submit job ${jid1##* }: ${pbEnv} && /sw/bin/samtools merge -@${THREAD} -c ${outDir}/${outFilePrefix}.bam ${outDir}/${outFilePrefix}.*.bam"
	# create index file 
	jid1=$(sbatch -c ${THREAD} -n 1 --dependency=afterok:"${jid1##* }" -J pbindex --mem=${mem} -p ${partition} --time=${tim} --wrap="${pbEnv} && pbindex ${outDir}/${outFilePrefix}.bam")
	echo "submit job ${jid1##* }: ${pbEnv} && pbindex ${outDir}/${outFilePrefix}.bam"
done

