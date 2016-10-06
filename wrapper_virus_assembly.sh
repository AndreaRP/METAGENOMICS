#!/bin/bash
set -e

#########################################################
#		  		VIRUS ASSEMBLY WRAPPER				 	#
#########################################################

# 1. Runs assembly.sh* with every sample included in samples_id.txt**
# * Note: This script must only be used after running wrapper_virus_mapper.sh
# ** Note: the file samples_id.txt is generated by samplesID_gen.sh

#       CONSTANTS
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
virDB="${workingDir}REFERENCES/VIRUS_GENOME_REFERENCE/"

source ${workingDir}ANALYSIS/SRC/assembly.sh
cat ${workingDir}/ANALYSIS/samples_id.txt | while read in
do
	mappedDir="${workingDir}ANALYSIS/06-virus/${in}/reads/"
	assemble $mappedDir
done
