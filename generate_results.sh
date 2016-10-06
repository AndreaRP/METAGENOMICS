#!/bin/bash
set -e

#########################################################
#		  		HTML RESULTS GENERATOR				 	#
#########################################################

# 1. Copy Utilities (css, icons and js files)
# 2. Generates quality report
# * Note: the file samples_id.txt is generated by samplesID_gen.sh


#       CONSTANTS	
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
resultsDir="${workingDir}RESULTS/"

########## COPY UTILITIES ############
cp -r ${workingDir}ANALYSIS/SRC/html/css* ${resultsDir}
cp -r ${workingDir}ANALYSIS/SRC/html/img* ${resultsDir}
cp -r ${workingDir}ANALYSIS/SRC/html/js* ${resultsDir}



########## QUALITY REPORT #############

#	CREATE DIRECTORY FOR THE SAMPLE IF NECESSARY
if [ ! -d "${resultsDir}quality" ]
then
	mkdir -p "${resultsDir}quality"
	echo -e "${resultsDir}quality created"
fi

# Copy Utilities
cp -r ${workingDir}ANALYSIS/SRC/html/quality/ ${resultsDir}
# Copy data 
cp -r ${workingDir}ANALYSIS/99-stats/data* ${resultsDir}quality

# Change to quality dir
cd ${resultsDir}quality

# generate fastqc report: 
perl ./listFastQCReports.pl ${resultsDir}quality/data/ > ${resultsDir}quality/table.html
perl ./createHTML.pl

rm ./template.html
rm ./table.html
rm ./listFastQCReports.pl
rm ./createHTML.pl

cd ${workingDir}

######### PER SAMPLE ########

# Run mergeSamples.R for each organism and sample
organisms=()
for organism in ${workingDir}ANALYSIS/*
do
	organism=$(echo $organism | rev | cut -d'/' -f1 | rev)
	if [[ $organism =~ ^[0]{1}[5-9] ]];
	then
		cat ${workingDir}ANALYSIS/samples_id.txt | while read sample
		do
			${workingDir}ANALYSIS/SRC/mergeResults.R $sample $organism
		done
	fi
done

########## SUMMARY ##########
