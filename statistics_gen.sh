#!/bin/bash
set -e
#       
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
percentageFile="${workingDir}RESULTS/percentageFile.txt"
declare -a organisms=("bacteria" "virus" "fungi" "protozoa" "invertebrate")
#readarray samples < ${workingDir}ANALYSIS/samples_id.txt
#awk 'BEGIN { printf "Sample Id\tBacteria\tVirus\tFungi\tProtozoa\tInvertebrate\tUnknown" }' > $percentageFile
cat ${workingDir}ANALYSIS/samples_id.txt | while read sampleName
do
	echo $sampleName | awk '{ printf "\n" $1 "\t" }' >> $percentageFile
	for organism in "${organisms[@]}"
	do
#		echo $organism
		logFile="${workingDir}ANALYSIS/*${organism}/${sampleName}/reads/*_mapping.log"
        cat $logFile | while read line
		do
			echo $line | awk '{if($2 == "overall") { gsub("%",""); printf $1 "\t"} }' >> $percentageFile
		done
	done
done

