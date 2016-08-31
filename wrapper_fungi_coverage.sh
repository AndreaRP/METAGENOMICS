#!/bin/bash
set -e
#       execute coverage script
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
fungiDB="${workingDir}REFERENCES/FUNGI_GENOME_REFERENCE/"
cat ${workingDir}ANALYSIS/samples_id.txt | while read in
do
	sampleDir="${workingDir}ANALYSIS/07-fungi/${in}/"
	${workingDir}ANALYSIS/SRC/coverage.sh $sampleDir $fungiDB
done
