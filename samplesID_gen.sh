#!/bin/bash
set -e 

#########################################################
#		  			SAMPLES ID READER				 	#
#########################################################

# 1. Gets the sample name from the file names in 00-reads folder. 
# Given raw read files with the following name structure: 
# sampleName_*R1*.fastq.gz and sampleName_*R2*.fastqc.gz the sample name will be the word before the first '_' in the R1 reads file.
# Note: the file samples_id.txt is generated by samplesID_gen.sh

# Input Files (In workingDir/ANALYSIS/00-reads/)
# sampleName1_*R1*.fastq.gz
# sampleName1_*R2*.fastq.gz
# sampleName2_*R1*.fastq.gz
# sampleName2_*R2*.fastq.gz
# sampleName3_*R1*.fastq.gz
# sampleName3_*R2*.fastq.gz
# ...

# Output Files (in workingDir/ANALYSIS/)
# samples_id.txt: File containing a list with the name of each sample.  

#	CONSTANTS
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
readFolder="${workingDir}ANALYSIS/00-reads/"

for file in ${readFolder}*R1*.fastq.gz
do
	sampleName=$(echo $file | rev | cut -d'/' -f1 | rev)
	echo $sampleName | awk -F '_' '{print $1}' >> samples_id.txt
done
