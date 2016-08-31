#!/bin/bash
set -e
#       execute fungi mapping script
source /processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/ANALYSIS/SRC/mapper_fungi.sh
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
fungiDB="${workingDir}REFERENCES/FUNGI_GENOME_REFERENCE/"
cat /processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/ANALYSIS/samples_id.txt | while read in
do
	map_fungi $fungiDB $in
done
