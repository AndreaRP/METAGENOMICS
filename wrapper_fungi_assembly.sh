#!/bin/bash
set -e
#       execute assembly script
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
source ${workingDir}ANALYSIS/SRC/assembly.sh
cat ${workingDir}/ANALYSIS/samples_id.txt | while read in
do
	mappedDir="${workingDir}ANALYSIS/07-fungi/${in}/reads/"
	assemble $mappedDir
done
