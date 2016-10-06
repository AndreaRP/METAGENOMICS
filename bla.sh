#/bin/bash
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'

organisms=()
for organism in ${workingDir}/analysis_Unai/ANALYSIS/*
do
	organism=$(echo $organism | rev | cut -d'/' -f1 | rev)
	if [[ $organism =~ ^[0]{1}[5-9] ]];
	then
		cat ${workingDir}analysis_Unai/ANALYSIS/samples_id.txt | while read sample
		do
			${workingDir}ANALYSIS/SRC/mergeResults.R $sample $organism
		done
	fi
done
