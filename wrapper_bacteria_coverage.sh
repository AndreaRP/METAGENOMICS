#!/bin/bash
set -e
#       execute bacteria mapping script
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
bacDB="${workingDir}REFERENCES/BACTERIA_GENOME_REFERENCE/"
cat ${workingDir}ANALYSIS/samples_id.txt | while read in
do
	sampleDir="${workingDir}ANALYSIS/05-bacteria/${in}/"
	${workingDir}ANALYSIS/SRC/coverage.sh $sampleDir $bacDB
done

