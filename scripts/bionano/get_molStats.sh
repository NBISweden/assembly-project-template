PROJECT_LIST=()

for PROJECT_BASE in "${PROJECT_LIST[@]}";do

	echo "runID	length	SNR	NumLabels" >& ${PROJECT_BASE}_outBNXStats.txt

	zcat ../../data/bionano/${PROJECT_BASE}_RawMolecules.bnx.gz | awk '{if($10~"chips") print $12, $3, $5, $6}' >> ${PROJECT_BASE}_outBNXStats.txt

	Rscript --vanilla get_BionanoQCStats.R ${PROJECT_BASE}_outBNXStats.txt

	echo "### ${PROJECT_BASE}" >> ../bionano_summary.txt
	echo "![Bionano molecule report](QC/bionano/${PROJECT_BASE}_outBNXStats.txt_BionanoQC.jpeg)" >> ../bionano_summary.txt
done

sed -i '/BioNano_summary/r ../bionano_summary.txt' ../../README.md

git add ../../README.md
git add -f ../../QC/bionano/*.jpeg
git commit -m "Added bionano molecule report image"
git push origin master
