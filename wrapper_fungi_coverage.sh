#!/bin/bash
set -e

#########################################################
#		  		FUNGI COVERAGE WRAPPER				 	#
#########################################################

# 1. Runs coverage.sh* with every sample included in samples_id.txt**
# * Note: This script must only be used after running wrapper_fungi_mapper.sh
# ** Note: the file samples_id.txt is generated by samplesID_gen.sh

#       CONSTANTS
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
fungiDB="${workingDir}REFERENCES/FUNGI_GENOME_REFERENCE/"

cat ${workingDir}ANALYSIS/samples_id.txt | while read in
do
	sampleDir="${workingDir}ANALYSIS/07-fungi/${in}/"
	${workingDir}ANALYSIS/SRC/coverage.sh $sampleDir $fungiDB
done