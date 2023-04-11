bash /projects/dazzler/pippel/prog/MARVEL/DAMAR_OLD-build/DAmar_TRACE_XOVR_125/scripts/marvel_slurm.sh ./LongRanger/asm_fAntPal.longranger.config.sh

bash /projects/dazzler/pippel/prog/MARVEL/DAMAR_OLD-build/DAmar_TRACE_XOVR_125/scripts/marvel_slurm.sh ./supernova/asm_fAntPal.supernova.config.sh

PROJECT_ID=asm_fAntPal

sed -i "/LongRanger/r ../assembly/10X/supernova/10x_${PROJECT_ID:4:7}1_supernova/outs/report.txt" ../README.md
