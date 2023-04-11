PROJECT_ID=asm_fAntPal
GSIZE=2500M

sed "s/{{PROJECT_ID}}/${PROJECT_ID}/g" ./pacbio_stats/submit_pacBioStats.template.slurm >& ./pacbio_stats/submit_pacBioStatslofi.slurm
sed -i "s/{{pb_type}}/lofi/g" ./pacbio_stats/submit_pacBioStatslofi.slurm

sed "s/{{GENOME_SIZE}}/${GSIZE}/g" ./pacbio_stats/run_allBamFiles.template.sh >& ./pacbio_stats/run_allBamFilesLoFi.sh
sed -i "s/{{PROJECT_NAME}}/${PROJECT_ID}/g" ./pacbio_stats/run_allBamFilesLoFi.sh
sed -i "s/{{pb_type}}/lofi/g" ./pacbio_stats/run_allBamFilesLoFi.sh

sed "s/{{pb_type}}/lofi/g" ./pacbio_stats/extract_readLengths.template.R > ./pacbio_stats/extract_readLengths.lofi.R
sed "s/{{pb_type}}/lofi/g" ./pacbio_stats/get_runInfo.template.R > ./pacbio_stats/get_runInfo.lofi.R
sed "s/{{pb_type}}/lofi/g" ./pacbio_stats/read_xmlStats.template.R > ./pacbio_stats/read_xmlStats.lofi.R
sed "s/{{pb_type}}/lofi/g" ./pacbio_stats/write_mdFile.template.R > ./pacbio_stats/write_mdFile.lofi.R
sed "s/{{pb_type}}/lofi/g" make_effCovPlot.template.R > make_effCovPlot.R

sed "s/{{PROJECT_ID}}/${PROJECT_ID}/g" ./coverage/coverage.config.template.sh >& ./coverage/coverage.config.${PROJECT_ID}.lofi.sh
sed -i "s/{{DB_BASE}}/${PROJECT_ID}/g" ./coverage/coverage.config.${PROJECT_ID}.lofi.sh
sed -i "s/{{GSIZE}}/${GSIZE}/g" ./coverage/coverage.config.${PROJECT_ID}.lofi.sh
sed -i "s/PB_TYPE/lofi/g" ./coverage/coverage.config.${PROJECT_ID}.lofi.sh

sed "s/{{pb_type}}/lofi/g" plot_lowCompTable.template.R >& plot_lowCompTable.R

sed "s/{{PROJECT_ID}}/${PROJECT_ID}/g" bamtoDB.template.slurm >& bamtoDB.LoFi.slurm
sed -i "s/{{pb_type}}/lofi/g" bamtoDB.LoFi.slurm

echo -e "\n ## PacBio LoFi Coverage estimate\n" >& /projects/dazzlerAssembly/${PROJECT_ID}/scripts/pacbio_lofisummary.txt
echo -e "\n![Coverage estimate](QC/pacbio/lofi/coverage/${PROJECT_ID}_Z_effCovEstimate.jpeg)\n" >> /projects/dazzlerAssembly/${PROJECT_ID}/scripts/pacbio_lofisummary.txt

echo -e "\n ## PacBio LoFi Low Complexity estimate\n" >> /projects/dazzlerAssembly/${PROJECT_ID}/scripts/pacbio_lofisummary.txt
echo -e "\n![Low complexity table](QC/pacbio/lofi/coverage/${PROJECT_ID}_maskStats.jpeg)\n" >> /projects/dazzlerAssembly/${PROJECT_ID}/scripts/pacbio_lofisummary.txt
echo -e "\n![Low complexity summary](QC/pacbio/lofi/coverage/${PROJECT_ID}_lowCompSummary.md)\n" >> /projects/dazzlerAssembly/${PROJECT_ID}/scripts/pacbio_lofisummary.txt

echo -e "\n ## PacBio LoFi bam files\n" >> /projects/dazzlerAssembly/${PROJECT_ID}/scripts/pacbio_lofisummary.txt

for i in "../data/pacbio/lofi/*.subreads.bam";do
	bamfileName=$(basename $i)
	bamFileBase=${bamfileName%%.*}
	echo -e "\n[${bamFileBase}](QC/pacbio/lofi/read_stats/${bamFileBase}.md)" >> /projects/dazzlerAssembly/${PROJECT_ID}/scripts/pacbio_lofisummary.txt
done

cd pacbio_stats 
bash run_allBamFilesLoFi.sh

cd ../
sbatch bamtoDB.LoFi.slurm

git add -f ./coverage/coverage.config.${PROJECT_ID}.lofi.sh
git add -f ./pacbio_stats/*.R
git add -f ./pacbio_stats/*.sh
git add -f ./pacbio_stats/*.slurm
git add -f bamtoDB.LoFi.slurm
git add ../README.md

git commit -m "Setup submission scripts for pacbio lofi data"

git push origin master
