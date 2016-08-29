#!/bin/bash
set -e 

readFolder='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/ANALYSIS/00-reads/'

for file in ${readFolder}*R1*.fastq.gz
do
	sampleName=$(echo $file | rev | cut -d'/' -f1 | rev)
	echo $sampleName | awk -F '_' '{print $1}' >> samples_id.txt
done

