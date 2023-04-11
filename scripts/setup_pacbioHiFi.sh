PROJECT_ID=asm_fAntPal
GSIZE=2500M

sed "s/{{PROJECT_ID}}/${PROJECT_ID}/g" ./pacbio_stats/submit_pacBioStats.template.slurm >& ./pacbio_stats/submit_pacBioStatshifi.slurm
sed -i "s/{{pb_type}}/hifi/g" ./pacbio_stats/submit_pacBioStatshifi.slurm

sed "s/{{PROJECT_ID}}/${PROJECT_ID}/g" run_HiFiConsensus.template.sh >& run_HifiConsensus.sh

sed "s/{{GENOME_SIZE}}/${GSIZE}/g" ./pacbio_stats/run_allBamFiles.template.sh >& ./pacbio_stats/run_allBamFileshifi.sh
sed -i "s/{{PROJECT_NAME}}/${PROJECT_ID}/g" ./pacbio_stats/run_allBamFileshifi.sh
sed -i "s/{{pb_type}}/hifi/g" ./pacbio_stats/run_allBamFileshifi.sh

sed "s/{{pb_type}}/hifi/g" ./pacbio_stats/extract_readLengths.template.R >& ./pacbio_stats/extract_readLengths.hifi.R
sed "s/{{pb_type}}/hifi/g" ./pacbio_stats/get_runInfo.template.R >& ./pacbio_stats/get_runInfo.hifi.R
sed "s/{{pb_type}}/hifi/g" ./pacbio_stats/read_xmlStats.template.R >& ./pacbio_stats/read_xmlStats.hifi.R
sed "s/{{pb_type}}/hifi/g" ./pacbio_stats/write_mdFile.template.R >& ./pacbio_stats/write_mdFile.hifi.R

sed "s/{{PROJECT_ID}}/${PROJECT_ID}/g" ./coverage/coverage.config.template.sh >& ./coverage/coverage.config.${PROJECT_ID}.hifi.sh
sed -i "s/{{DB_BASE}}/${PROJECT_ID}/g" ./coverage/coverage.config.${PROJECT_ID}.hifi.sh
sed -i "s/{{GSIZE}}/${GSIZE}/g" ./coverage/coverage.config.${PROJECT_ID}.hifi.sh
sed -i "s/{{pb_type}}/hifi/g" ./coverage/coverage.config.${PROJECT_ID}.hifi.sh
sed -i "s/PB_TYPE/hifi/g" ./coverage/coverage.config.${PROJECT_ID}.hifi.sh

sed "s/{{pb_type}}/hifi/g" make_effCovPlot.template.R >& make_effCovPlot.R

echo -e "\n ## PacBio HiFi Coverage estimate\n" >& /projects/dazzlerAssembly/${PROJECT_ID}/scripts/pacbio_hifisummary.txt
echo -e "\n![Coverage estimate](QC/pacbio/hifi/coverage/${PROJECT_ID}_Z_effCovEstimate.jpeg)\n" >> /projects/dazzlerAssembly/${PROJECT_ID}/scripts/pacbio_hifisummary.txt

echo -e "\n ## PacBio HiFi bam files\n" >> /projects/dazzlerAssembly/${PROJECT_ID}/scripts/pacbio_hifisummary.txt

for i in ../data/pacbio/hifi/*.subreads.bam;do
        bamfileName=$(basename $i)
        bamFileBase=${bamfileName%%.*}
        echo -e "\n[${bamFileBase}](QC/pacbio/hifi/read_stats/${bamFileBase}.md)" >> ../pacbio_hifisummary.txt
done

cd pacbio_stats 
bash run_allBamFileshifi.sh

cd ../
#bash run_HiFiConsensus.sh

git add -f ./coverage/coverage.config.${PROJECT_ID}.hifi.sh
git add -f ./pacbio_stats/*.R
git add -f ./pacbio_stats/*.sh
git add -f ./pacbio_stats/*.slurm
git add -f bamtoDB.HiFi.slurm
git add ../README.md

git commit -m "Setup submission scripts for pacbio hifi data"


