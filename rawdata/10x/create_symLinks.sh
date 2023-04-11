PROJECT_ID={{PROJECT_ID}}1

i=1
for R1 in *R1.fastq.gz;do
	if [ $i -lt 10 ];then
		ln -s $R1 ${PROJECT_ID}_S1_L00${i}_R1_001.fastq.gz
	elif [ $i -lt 100 ];then
		ln -s $R1 ${PROJECT_ID}_S1_L0${i}_R1_001.fastq.gz
	else
		ln -s $R1 ${PROJECT_ID}_S1_L${i}_R1_001.fastq.gz
	fi
	i=$((i+1))
done
i=1
for R2 in *R2.fastq.gz;do
	if [ $i -lt 10 ];then
		ln -s $R2 ${PROJECT_ID}_S1_L00${i}_R2_001.fastq.gz
	elif [ $i -lt 100 ];then
		ln -s $R2 ${PROJECT_ID}_S1_L0${i}_R2_001.fastq.gz
	else
		ln -s $R2 ${PROJECT_ID}_S1_L${i}_R2_001.fastq.gz
	fi
	i=$((i+1))
done
