#!/bin/bash
set -e
#       execute virus coverage script
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
virDB="${workingDir}REFERENCES/VIRUS_GENOME_REFERENCE/"
cat ${workingDir}ANALYSIS/samples_id.txt | while read in
do
	sampleDir="${workingDir}ANALYSIS/06-virus/${in}/"
	${workingDir}ANALYSIS/SRC/coverage.sh $sampleDir $virDB
done
