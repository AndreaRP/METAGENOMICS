#!/bin/bash
set -e
#       execute bacteria mapping script
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
bacDB="${workingDir}REFERENCES/BACTERIA_GENOME_REFERENCE/"
source ${workingDir}ANALYSIS/SRC/assembly.sh
cat /processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/ANALYSIS/samples_id.txt | while read in
do
	mappedDir="${workingDir}ANALYSIS/05-bacteria/${in}/reads/"
	assemble $mappedDir
done

