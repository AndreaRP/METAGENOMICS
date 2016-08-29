#!/bin/bash
#set -e
#       execute blast script
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
virDB="${workingDir}REFERENCES/VIRUS_GENOME_REFERENCE/"
source ${workingDir}ANALYSIS/SRC/blast.sh
cat ${workingDir}ANALYSIS/samples_id.txt | while read in
do
	sampleDir="${workingDir}ANALYSIS/06-virus/${in}/"
	blast $sampleDir $virDB
done
