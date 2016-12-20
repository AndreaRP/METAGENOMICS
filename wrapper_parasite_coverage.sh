#!/bin/bash
set -e

#########################################################
#		  	PARASITE COVERAGE WRAPPER				 	#
#########################################################

# 1. Runs coverage.sh* with every sample included in samples_id.txt**
# * Note: This script must only be used after running wrapper_parasite_mapper.sh
# ** Note: the file samples_id.txt is generated by samplesID_gen.sh

#       CONSTANTS
source ./pikaVirus.config
samplesIdFile="${analysisDir}/samples_id.txt"

# Calculates coverage for each sample
if [ "${cluster}" == "yes" ] # qsub -V -j y -b y -cwd -t 1-number of samples -q all.q -N name command
then
	in=$(awk "NR==$SGE_TASK_ID" $samplesIdFile)
	sampleProtozoaDir="${analysisDir}/08-protozoa/${in}/"
	sampleInvertebrateDir="${analysisDir}/09-invertebrate/${in}/"
	${analysisDir}/SRC/coverage.sh $sampleProtozoaDir $protozoaDB
	${analysisDir}/SRC/coverage.sh $sampleInvertebrateDir $invertebrateDB
else
	cat ${analysisDir}/samples_id.txt | while read in
	do
		sampleProtozoaDir="${analysisDir}/08-protozoa/${in}/"
		sampleInvertebrateDir="${analysisDir}/09-invertebrate/${in}/"
		${analysisDir}/SRC/coverage.sh $sampleProtozoaDir $protozoaDB
		${analysisDir}/SRC/coverage.sh $sampleInvertebrateDir $invertebrateDB
	done
fi
