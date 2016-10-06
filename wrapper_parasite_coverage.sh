#!/bin/bash
set -e

#########################################################
#		  	PARASITE COVERAGE WRAPPER				 	#
#########################################################

# 1. Runs coverage.sh* with every sample included in samples_id.txt**
# * Note: This script must only be used after running wrapper_parasite_mapper.sh
# ** Note: the file samples_id.txt is generated by samplesID_gen.sh

#       CONSTANTS
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
protozoaDB="${workingDir}REFERENCES/PROTOZOA_GENOME_REFERENCE/"
invertebrateDB="${workingDir}REFERENCES/INVERTEBRATE_GENOME_REFERENCE/"

cat ${workingDir}ANALYSIS/samples_id.txt | while read in
do
	sampleProtozoaDir="${workingDir}ANALYSIS/08-protozoa/${in}/"
	sampleInvertebrateDir="${workingDir}ANALYSIS/09-invertebrate/${in}/"
	${workingDir}ANALYSIS/SRC/coverage.sh $sampleProtozoaDir $protozoaDB
	${workingDir}ANALYSIS/SRC/coverage.sh $sampleInvertebrateDir $invertebrateDB
done
