#!/bin/bash
set -e
#########################################################
#		  SCRIPT TO EVALUATE COVERAGE				 	#
#########################################################
# 1. Creates necessary directories. 
# 2. Calculates coverage using bedtools.
# 3. Creates coverage files and graphs using R.
# Note: This script can only be run after mapping against a reference using the appropiate mapper_organism.sh script.
 
# Arguments:
# $1 = (sampleDir) Directory where the analysis is. (ANALYSIS/xx-organism/sampleName/) 
# $2 = (refDB) Directory with the references. (/REFERENCES/ORGANISM_GENOME_REFERENCE)

# Input Files:
# genomeLength: List of the length of each of the genomes in the reference DB
# sampleBam: BAM file 

# Output files: (In ANALYSIS/xx-organism/sampleName/coverage)
# sampleName_genome_coverage.txt: Coverage file from the BAM file.
# sampleName_coverage_log.log: Log file.


#	GET ARGUMENTS
sampleDir=$1  #workingDir/ANALYSIS/xx-organism/sampleName/
refDB=$2
#	INITIALIZE VARIABLES
#		Constants
sampleName=$(basename $sampleDir) # (sampleName)
organismDir=$(echo $sampleDir | rev | cut -d'/' -f3 | rev) # (xx-organism)
organism="${organismDir##*-}" # (organism)
workingDir="$(echo $sampleDir | rev | cut -d'/' -f4- | rev)/SRC/" # (ANALYSIS/SRC/) 
#		Input Files
genomeLength="${refDB}/WG/genome_length.txt"
16SLength="${refDB}/16S/*length.txt"
ITSLength="${refDB}/ITS/*length.txt"
sampleBam="${sampleDir}/reads/*sorted.bam"
16SBam="${sampleDir}/reads/offrate/*sorted.bam"
ITSBam="${sampleDir}/reads/offrate/*sorted.bam"
#		Output Files
genomeCov="${sampleDir}/coverage/${sampleName}_genome_coverage.txt"
16SCov="${sampleDir}/coverage/${sampleName}_16S_coverage.txt"
ITSCov="${sampleDir}/coverage/${sampleName}_ITS_coverage.txt"
lablog="${sampleDir}/coverage/${sampleName}_coverage_log.log"

# load programs in module (comment for local runs) 
module load bedtools2/bedtools2-2.25.0
module load R/R-3.2.5

echo -e "$(date)" 
echo -e "*********** CALCULATING COVERAGE OF $organism IN SAMPLE $sampleName ************"

#	CREATE DIRECTORY FOR THE SAMPLE IF NECESSARY
if [ ! -d "${sampleDir}/coverage/" ]
then
	mkdir -p "${sampleDir}/coverage/"
	echo -e "${sampleDir}/coverage/ created"
fi

################################################################################################
#					COVERAGE
################################################################################################
echo -e "$(date)\t start running genomecov for ${sampleName}\n" > $lablog
echo -e "The command is: ### bedtools genomecov -ibam $sampleBam -g $genomeLength > $genomeCov ###" >> $lablog
bedtools genomecov -ibam $sampleBam -g $genomeLength > $genomeCov
echo -e "$(date)\t finished running genomecov for ${sampleName}\n" >> $lablog

#################################################################################################
# If the reference is bacteria
if [ -e "$16SLength" ]
then
	echo -e "$(date)\t start running genomecov for ${sampleName} 16S\n" > $lablog
	echo -e "The command is: ### bedtools genomecov -ibam $16SBam -g $16SLength > $16SCov ###" >> $lablog
	bedtools genomecov -ibam $16SBam -g $16SLength > $16SCov
	echo -e "$(date)\t finished running genomecov for ${sampleName} 16S\n" >> $lablog
fi

################################################################################################	
# If the reference is fungi
if [ -e "$ITSLength" ]
then
	echo -e "$(date)\t start running genomecov for ${sampleName} ITS\n" > $lablog
	echo -e "The command is: ### bedtools genomecov -ibam $ITSBam -g $ITSLength > $ITSCov ###" >> $lablog
	bedtools genomecov -ibam $ITSBam -g $ITSLength > $ITSCov
	echo -e "$(date)\t finished running genomecov for ${sampleName} ITS\n" >> $lablog
fi

################################################################################################
#					GRAPHICS
################################################################################################
echo -e "$(date)\t start generating coverage graphs for ${sampleName}\n" >> $lablog
echo -e "The command is: ### Rscript --vanilla ${sampleDir}/coverage/ ${sampleName} ###" >> $lablog
Rscript --vanilla "${workingDir}/graphs_coverage.R" "${sampleDir}/coverage/" ${sampleName}
echo -e "$(date)\t finished coverage graphs for ${sampleName}\n" >> $lablog


if [ -e "$16SLength" ]
then
	Rscript --vanilla "${workingDir}/16S_coverage.R" "${sampleDir}/coverage/" ${sampleName}
fi



