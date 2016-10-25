#!/bin/bash
set -e

#########################################################
#		  		HTML RESULTS GENERATOR				 	#
#########################################################

# 1. Copy web utilities (css, icons and js files)
# 2. Generates info html file
# 3. Creates quality directory if necessary
# 4. Generates quality report (with scripts: ANALYSIS/SRC/html/quality/listFastQCReports.pl and ANALYSIS/SRC/html/quality/createHTML.pl)
# 5. Creates data directory in RESULTS if necessary
# 6. Generates merged results table (with script ANALYSIS/SRC/mergeResults.R)
# 7. Creates results html for each sample and analysed organism. (with script: ANALYSIS/SRC/createResultHtml.sh)
# 8. Generates result summary of each sample 
# * Note: This script should only be run after the analysis has finished.


# load programs in module (comment for local runs) 
module load R/R-3.2.5

#       CONSTANTS	
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
resultsDir="${workingDir}RESULTS/"
lablog="${resultsDir}_results_log.log"

############### COPY UTILITIES ################	
echo -e "$(date)\t start copying utilities (css, js, img...)\n" > $lablog
echo -e "The commands are:\ncp -r ${workingDir}ANALYSIS/SRC/html/css* ${resultsDir}\ncp -r ${workingDir}ANALYSIS/SRC/html/img* ${resultsDir}\ncp -r ${workingDir}ANALYSIS/SRC/html/js* ${resultsDir}
" > $lablog
cp -r ${workingDir}ANALYSIS/SRC/html/css* ${resultsDir}
cp -r ${workingDir}ANALYSIS/SRC/html/img* ${resultsDir}
cp -r ${workingDir}ANALYSIS/SRC/html/js* ${resultsDir}
echo -e "$(date)\t finished copying utilities into $resultsDir" >> $lablog

################## WHAT IS THIS? ##############
echo -e "$(date)\t start copying info.html into $resultsDir" >> $lablog
echo -e "The command is:\ncp ${workingDir}ANALYSIS/SRC/html/info.html ${resultsDir}" >> $lablog
cp ${workingDir}ANALYSIS/SRC/html/info.html ${resultsDir}

########## QUALITY REPORT #############

#	CREATE DIRECTORY FOR THE SAMPLE IF NECESSARY
if [ ! -d "${resultsDir}quality" ]
then
	mkdir -p "${resultsDir}quality"
	echo -e "$(date)\t Generate ${resultsDir}quality" >> $lablog
	echo -e "${resultsDir}quality created"
fi

# Copy quality utilities
echo -e "$(date)\t Start copying utilities for quality results:" >> $lablog
echo -e "cp -r ${workingDir}ANALYSIS/SRC/html/quality/ ${resultsDir}" >> $lablog
cp -r ${workingDir}ANALYSIS/SRC/html/quality/ ${resultsDir}
# Copy data 
echo -e "cp -r ${workingDir}ANALYSIS/99-stats/data* ${resultsDir}quality" >> $lablog
cp -r ${workingDir}ANALYSIS/99-stats/data* ${resultsDir}quality

# Change to quality dir
cd ${resultsDir}quality

# generate fastqc report: 
echo -e "Generate fastq report:" >> $lablog
echo -e "perl ./listFastQCReports.pl ${resultsDir}quality/data/ > ${resultsDir}quality/table.html" >> $lablog
perl ./listFastQCReports.pl ${resultsDir}quality/data/ > ${resultsDir}quality/table.html
echo -e "perl ./createHTML.pl" >> $lablog
perl ./createHTML.pl

echo -e "Removing template.html, table.html, listFastQCReports.pl and createHTML.pl" >> $lablog
rm ./template.html
rm ./table.html
rm ./listFastQCReports.pl
rm ./createHTML.pl

# Copy quality template html file
echo -e "$(date)\t Copy the quality template page:" >> $lablog
echo -e "cp ${workingDir}ANALYSIS/SRC/html/quality.html ${resultsDir}" >> $lablog
cp ${workingDir}ANALYSIS/SRC/html/quality.html ${resultsDir}

cd ${workingDir}


######### PER SAMPLE ########

#	CREATE DIRECTORY FOR THE SAMPLE IF NECESSARY
if [ ! -d "${resultsDir}data/persamples" ]
then
	mkdir -p "${resultsDir}data/persamples"
	echo -e "$(date)\t Generate ${resultsDir}data/persamples" >> $lablog
	echo -e "${resultsDir}data/persamples created"
fi

# Generate by sample template html
echo -e "$(date)\t Run script to generate BySample template:" >> $lablog
echo -e "bash ${workingDir}ANALYSIS/SRC/createSamplesHtml.sh ${workingDir}" >> $lablog
bash ${workingDir}ANALYSIS/SRC/createSamplesHtml.sh ${workingDir} 2>&1 | tee -a $lablog

# Generate actual sample data html files
echo -e "$(date)\t Generate actual data sample html files" >> $lablog
organisms=()
for organism in ${workingDir}ANALYSIS/*
do
	organism=$(echo $organism | rev | cut -d'/' -f1 | rev)
	if [[ $organism =~ ^[0]{1}[5-9] ]];
	then
		cat ${workingDir}ANALYSIS/samples_id.txt | while read sample
		do
			echo -e "$sample" >> $lablog
			# Create results table
			echo -e "\t$(date)\t Create results table (.txt)" >> $lablog
			echo -e "\t$(date)\t Rscript ${workingDir}ANALYSIS/SRC/mergeResults.R $sample $organism" >> $lablog
			Rscript ${workingDir}ANALYSIS/SRC/mergeResults.R $sample $organism 2>&1 | tee -a $lablog
			# Create results html
			sampleDir=$1  #/workingDir/ANALYSIS/xx-organism/sampleName/
			echo -e "\t$(date)\t Create results html file" >> $lablog
			echo -e "\t$(date)\t ${workingDir}ANALYSIS/SRC/createResultHtml.sh ${workingDir}ANALYSIS/${organism}/${sample}/" >> $lablog
			${workingDir}ANALYSIS/SRC/createResultHtml.sh "${workingDir}ANALYSIS/${organism}/${sample}/" 2>&1 | tee -a $lablog 
		done
	fi
done


######### SUMMARY ###########


#	CREATE DIRECTORY FOR THE SAMPLE IF NECESSARY
if [ ! -d "${resultsDir}data" ]
then
	mkdir -p "${resultsDir}data/summary/"
	echo -e "$(date)\t Generate ${resultsDir}data/summary" >> $lablog
	echo -e "${resultsDir}data/summary created"
fi

# Generate taxonomy statistics files
echo -e "$(date)\t Generate taxonomy statistics files" >> $lablog
organisms=()
for organism in ${workingDir}ANALYSIS/*
do
	organism=$(echo $organism | rev | cut -d'/' -f1 | rev)
	if [[ $organism =~ ^[0]{1}[5-9] ]];
	then
		echo -e "$organism" >> $lablog
		organism_stripped="${organism##*-}" # gets what is after the '-' and assumes is the organism
		cat ${workingDir}ANALYSIS/samples_id.txt | while read sample
		do
			echo -e "\t$sample" >> $lablog
			# Generate taxonomy statistics
			echo -e "\t\t$(date)\t Generate taxonomy" >> $lablog
			echo -e "\t\t${workingDir}ANALYSIS/SRC/statistics.sh ${workingDir}ANALYSIS/${organism}/${sample}/blast" >> $lablog
			${workingDir}ANALYSIS/SRC/statistics.sh ${workingDir}ANALYSIS/${organism}/${sample}/blast 2>&1 | tee -a $lablog
			# Copy statistics files to RESULTS data folder
			cp "${workingDir}ANALYSIS/${organism}/${sample}/taxonomy/${sample}_${organism_stripped}_statistics.txt" "${resultsDir}/data/summary/" 2>&1 | tee -a $lablog
		done
	fi
done

# Generates the html file once the txt statistics are finished and copied.
echo -e "$(date)\t Create html file:" >> $lablog
echo -e "cp ${workingDir}ANALYSIS/SRC/html/summary.html ${resultsDir}" >> $lablog
cp ${workingDir}ANALYSIS/SRC/html/summary.html ${resultsDir}
