#!/bin/bash
set -e

##############
# STATISTICS #
##############
# 1. Creates necessary directories.
# 2. Gets a list of the organisms which appear in blast.
# 3. Format the list to get uniform taxonomy.
# INPUT FILES:


#refDB=$1    
blastDir=$1 #workingDir/ANALYSIS/xx-organism/sampleName/blast/



workingDir="/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/"
sampleName=$(echo $blastDir | rev | cut -d'/' -f3 | rev) #gets the second to last column (sampleName)
organismDir=$(echo $blastDir | rev | cut -d'/' -f4 | rev) # gets the 3 to last column (xx-organism)
organism="${organismDir##*-}" # gets what is after the '-' and assumes is the organism
sampleDir=$(echo $blastDir | rev | cut -d'/' -f3- | rev)
outputDir="${sampleDir}/taxonomy/"
blastFile="${blastDir}*_filtered.blast"

# CREATE DIRECTORY
if [ ! -d ${outputDir} ]
then
	mkdir -p $outputDir
	echo -e "${outputDir} created"
fi

cat $blastFile | cut -f 1,3 | sort | uniq > "${outputDir}/${sampleName}_organismList.txt"

cat "${outputDir}/${sampleName}_organismList.txt"| while read in
do
	case $organism in
		bacteria)
			#bla
			;;
		virus)
			#bla
			;;
		fungi)
			#bla
			;;
		protozoa)
			#bla
			;;
		invertebrate)
			#bla
			;;
		*) echo "Unknown organism"
	esac
done
