#!/bin/bash
set -e

#########################################################
#		  		BACTERIA MAPPER WRAPPER				 	#
#########################################################

# 1. Runs mapper_bac.sh* with every sample included in samples_id.txt**
# * Note: This script must only be used after running wrapper_host_removal.sh
# ** Note: the file samples_id.txt is generated by samplesID_gen.sh

#	CONSTANTS       
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
bacDB="${workingDir}REFERENCES/BACTERIA_GENOME_REFERENCE/"

source ${workingDir}ANALYSIS/SRC/mapper_bac_offrate_multicore.sh
cat ${workingDir}ANALYSIS/samples_id.txt | while read in
do
	map_bacteria $bacDB $in
done

