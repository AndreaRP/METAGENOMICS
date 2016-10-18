#!/bin/bash
set -e

#########################################################
#		  		HTML RESULTS GENERATOR				 	#
#########################################################

# 1. Copy web utilities (css, icons and js files)
# 2. Creates quality directory if necessary
# 3. Generates quality report (with scripts: ANALYSIS/SRC/html/quality/listFastQCReports.pl and ANALYSIS/SRC/html/quality/createHTML.pl)
# 4. Creates data directory in RESULTS if necessary
# 5. Generates merged results table (with script ANALYSIS/SRC/mergeResults.R)
# 6. Creates results html for each sample and analysed organism. (with script: ANALYSIS/SRC/createResultHtml.sh)
# 7. Generates result summary of each sample 
# 8. Generates info html file
# * Note: This script should only be run after the analysis has finished.


# load programs in module (comment for local runs) 
module load R/R-3.2.5

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

# Copy quality utilities
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

#	CREATE DIRECTORY FOR THE SAMPLE IF NECESSARY
if [ ! -d "${resultsDir}data" ]
then
	mkdir -p "${resultsDir}data"
	echo -e "${resultsDir}data created"
fi

# Generate by sample template html

bash ${workingDir}ANALYSIS/createSamplesHtml.sh ${workingDir}

# Generate actual sample data html files
organisms=()
for organism in ${workingDir}ANALYSIS/*
do
	organism=$(echo $organism | rev | cut -d'/' -f1 | rev)
	if [[ $organism =~ ^[0]{1}[5-9] ]];
	then
		cat ${workingDir}ANALYSIS/samples_id.txt | while read sample
		do
			# Create results table
			Rscript ${workingDir}ANALYSIS/SRC/mergeResults.R $sample $organism
			# Create results html
			sampleDir=$1  #/workingDir/ANALYSIS/xx-organism/sampleName/
			${workingDir}ANALYSIS/SRC/createResultHtml.sh "${workingDir}ANALYSIS/${organism}/${sample}/" 
		done
	fi
done


######### SUMMARY ###########

# Taxonomy

######### WHAT IS THIS? ###########
