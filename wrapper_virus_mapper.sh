#!/bin/bash
set -e
#       execute virus mapping script
source /processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/ANALYSIS/SRC/mapper_virus.sh
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
virDB="${workingDir}REFERENCES/VIRUS_GENOME_REFERENCE/"
cat ${workingDir}/ANALYSIS/samples_id.txt | while read in
do
	map_virus $virDB $in
done
