#!/bin/bash
#set -e
#       execute blast script
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
fungiDB="${workingDir}REFERENCES/FUNGI_GENOME_REFERENCE/"
source ${workingDir}ANALYSIS/SRC/blast.sh
cat ${workingDir}ANALYSIS/samples_id.txt | while read in
do
	sampleDir="${workingDir}ANALYSIS/07-fungi/${in}/"
	blast $sampleDir $fungiDB
done
