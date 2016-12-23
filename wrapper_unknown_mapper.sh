#!/bin/bash

set -e

#########################################################
#		  	BACTERIA ASSEMBLY WRAPPER				 	#
#########################################################

# 1. Runs assembly.sh* with every sample included in samples_id.txt**
# * Note: This script must only be used after running wrapper_bacteria_mapper.sh
# ** Note: the file samples_id.txt is generated by samplesID_gen.sh

#       CONSTANTS
source ./pikaVirus.config
source ${analysisDir}/SRC/mapper_unknown.sh
samplesIdFile="${analysisDir}/samples_id.txt"


if [ "${cluster}" -eq "yes" ] # qsub -V -j y -b y -cwd -t 1-number of samples -q all.q -N name command
then
	in=$(awk "NR==$SGE_TASK_ID" $samplesIdFile)
	echo $in
	map_unknown $in	
else
	cat ${analysisDir}/samples_id.txt | while read in
	do
		map_unknown $in
	done
fi

