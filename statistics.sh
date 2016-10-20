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
# Note: This script can be run after executing the blast.sh, please keep in mind that it is highly dependent
# of the format of the taxonomy of the reference database, and how the organism is described there.

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

# sort results by 1. query name (col=2), 2. bitscore (col=13), 3. evalue (col=12), 4. nucleotide identity (col=4), output only the necessary fields.
# And get only the first hit of each read (the best hit for each read)
cat $blastFile | sort -t$'\t' -rk2,2 -k13,13 -rk12,13 -rk4,4 | cut -f 1,3,2,13,12,4 | sort -t$'\t' -uk2,2 > "${outputDir}/${sampleName}_organismList.txt"

#cat $blastFile | cut -f 1,3 | sort | uniq -c > "${outputDir}/${sampleName}_organismList.txt"

rm -f "${outputDir}/${sampleName}_formated_organismList.txt"

cat "${outputDir}/${sampleName}_organismList.txt"| while read entry
do
	case $organism in
		bacteria)
			# Corynebacteriales bacterium X1698, complete genome	NODE_10_length_377_cov_2.36646	NZ_CP012390.1	97.21	4e-116	  425
			echo "${entry}" | awk -F"	" 'BEGIN{OFS="\t";} {sub(/,/,"");sub(/genome/,"");sub(/strain/,"");sub(/str./,"");sub(/complete/,"");sub(/sequence/,"");sub(/assembly/,"");print $1, $3, $4, $5, $6}' >> "${outputDir}/${sampleName}_formated_organismList.txt"
			# Corynebacteriales bacterium X1698   NZ_CP012390.1   97.21   4e-116    425
			cat "${outputDir}/${sampleName}_formated_organismList.txt" | cut -f 1 | uniq -c >>  "${outputDir}/${sampleName}_statistics.txt"
			;;
		virus)
			# 13 Human adenovirus 2, complete genome  AC_98655
			echo "${entry}" | awk -F"	" 'BEGIN{OFS="\t";} {sub(/,/,"");sub(/genome/,"");sub(/strain/,"");sub(/str./,"");sub(/complete/,"");sub(/sequence/,"");sub(/assembly/,"");print $1, $3, $4, $5, $6}' >> "${outputDir}/${sampleName}_formated_organismList.txt"
			cat "${outputDir}/${sampleName}_formated_organismList.txt" | cut -f 1 | uniq -c >>  "${outputDir}/${sampleName}_statistics.txt"
			# 13 Human adenovirus 2 ...
			;;
		fungi)
			# dna:supercontig supercontig:ASM15152v1:GG729702:1:504:1	NODE_5_length_195_cov_12.1357	puccinia_triticina|GG729702	90.05	7e-63	  244
			fun=$(echo ${entry} | cut -f2 -d'	')
			#number=$(echo ${fun} |   cut -f1 -d' ') # 11
			fun=$(echo ${fun} |   cut -f1 -d'|') # puccinia_triticina|GG729702
			sp=$(echo ${fun} |   cut -f4 -d' ') # puccinia_triticina
			sp="$(tr '[:lower:]' '[:upper:]' <<< ${sp:0:1})${sp:1}"
			sp=$(echo $sp | awk '{sub(/strain/,"");sub(/str./,"");sub(/complete genome/,"");sub(/_/," "); print}')
			echo "${entry}" | awk -F"	" -v sp="$sp" 'BEGIN{OFS="\t";} {sub(/,/,"");sub(/genome/,"");sub(/strain/,"");sub(/str./,"");sub(/complete/,"");sub(/sequence/,"");sub(/assembly/,"");print sp,$4, $5, $6}' >> "${outputDir}/${sampleName}_formated_organismList.txt"
			# Puccinia triticina 90.05   7e-63     244
			cat "${outputDir}/${sampleName}_formated_organismList.txt" | cut -f 1 | uniq -c >>  "${outputDir}/${sampleName}_statistics.txt"
			;;
		protozoa)
			#Perkinsus marinus ATCC 50983 genomic scaffold scf_1104296975874, whole genome shotgun sequence	NODE_2_length_593_cov_5.33643	NW_003200631.1	91.32	380	31	2	215	593	970	592	2e-144	  518  
			echo "${entry}" | awk -F"	" 'BEGIN{OFS="\t";} {sub(/,/,"");sub(/genomic/,"");sub(/assembly/,"");sub(/whole/,"");sub(/shotgun/,"");sub(/genome/,"");sub(/strain/,"");sub(/str./,"");sub(/complete/,"");sub(/sequence/,"");sub(/assembly/,"");print $1, $4, $5, $6}' >> "${outputDir}/${sampleName}_formated_organismList.txt"
			cat "${outputDir}/${sampleName}_formated_organismList.txt" | cut -f 1 | uniq -c >>  "${outputDir}/${sampleName}_statistics.txt"
			;;
		invertebrate)
			# Nematostella vectensis NEMVEscaffold_1252 genomic scaffold, whole genome shotgun sequence	NW_001833215.1  
			echo "${entry}" | awk -F"	" 'BEGIN{OFS="\t";} {sub(/,/,"");sub(/genomic/,"");sub(/assembly/,"");sub(/whole/,"");sub(/shotgun/,"");sub(/genome/,"");sub(/strain/,"");sub(/str./,"");sub(/complete/,"");sub(/sequence/,"");sub(/assembly/,"");print $1, $4, $5, $6}' >> "${outputDir}/${sampleName}_formated_organismList.txt"
			cat "${outputDir}/${sampleName}_formated_organismList.txt" | cut -f 1 | uniq -c >>  "${outputDir}/${sampleName}_statistics.txt"
			;;
		*) echo "Unknown organism"
	esac
done

