#!/bin/bash
set -e

##############
# STATISTICS #
##############
# 1. Creates necessary directories.
# 2. Gets a list of the organisms which appear in blast.
# 3. Format the list to get uniform taxonomy.
# INPUT FILES: (In ANALYSIS/xx-organism/sampleName/blast/)
# sampleName_filetered.blast: blast file generated after running blast.sh script.
# OUTPUT FILES: (In ANALYSIS/xx-organism/sampleName/taxonomy/)
# sampleName_organismList.txt: List of unique blast hits: unformated taxonomy, accession and number of hits. 
# sampleName_formated_organismList.txt: List of hits formated.


# ARGUMENTS    
blastDir=$1 #workingDir/ANALYSIS/xx-organism/sampleName/blast/

# CONSTANTS
workingDir="/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/"
sampleName=$(echo $blastDir | rev | cut -d'/' -f3 | rev) #gets the second to last column (sampleName)
organismDir=$(echo $blastDir | rev | cut -d'/' -f4 | rev) # gets the 3 to last column (xx-organism)
organism="${organismDir##*-}" # gets what is after the '-' and assumes is the organism
sampleDir=$(echo $blastDir | rev | cut -d'/' -f3- | rev)
outputDir="${sampleDir}/taxonomy/"
#	Input file
blastFile="${blastDir}*_filtered.blast"

# CREATE DIRECTORY
if [ ! -d ${outputDir} ]
then
	mkdir -p $outputDir
	echo -e "${outputDir} created"
fi

cat $blastFile | cut -f 1,3 | sort | uniq -c > "${outputDir}/${sampleName}_organismList.txt"

echo '' > "${outputDir}/${sampleName}_formated_organismList.txt"

cat "${outputDir}/${sampleName}_organismList.txt"| while read entry
do
	case $organism in
		bacteria)
			;;
		virus)
			# 13 Human adenovirus 2, complete genome
			vir=$(echo ${entry} | cut -f1 -d'	')
			vir=$(echo ${vir} | cut -f1 -d',')
			# 13 Human adenovirus 2 ...
			echo $vir >> "${outputDir}/${sampleName}_formated_organismList.txt"
			#$total=$(($total + $(echo $vir | cut -f1 -d' ')))
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

