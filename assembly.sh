set -e
#########################################################
#		  SCRIPT TO ASSEMBLE READS USING SPADES		 	#
#########################################################
# Arguments:
# $1 = (mappedDir) Group Directory. Directory where the fastq to be assembled are located.
# 1. Creates necessary directories. 
# 2. Assembles fastq files.
# 3. Runs quast to see quality
# Output files: (In ANALYSIS/sampleName/05.ASSEMBLY)
# sampleName_bacteria_sorted.sam: SAM file from mapping the processed files against the reference genome.
# sampleName_*_R1.fastq: .fastq file with R1 reads that mapped the DB.
# sampleName_*_R2.fastq: .fastq file with R2 reads that mapped the DB.
# sampleName_assembly.log: .log file with a log of the mapping.

function assemble {
#	GET ARGUMENTS
mappedDir=$1  #workingDir/ANALYSIS/xx-organism/sampleName/reads/
#	INITIALIZE VARIABLES
#		Organism
workingDir="/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/"
sampleName=$(echo $mappedDir | rev | cut -d'/' -f3 | rev) #gets the second to last column (sampleName)
organismDir=$(echo $mappedDir | rev | cut -d'/' -f4 | rev) # gets the 3 to last column (xx-organism)
organism="${organismDir##*-}" # gets what is after the '-' and assumes is the organism
#sampleAnalysisDir=$(echo $mappedDir | rev | cut -d'/' -f3- | rev) #gets the analysis directory of the sample (everything before the 3 column)
#		Directories
outputDir="$(echo $mappedDir | rev | cut -d'/' -f3- | rev)/contigs/" #where the contigs will be saved (workingDir/ANALYSIS/xx-organism/sampleName/contigs)
#		Input Files
mappedR1Fastq="${mappedDir}${sampleName}*_R1.fastq"
mappedR2Fastq="${mappedDir}${sampleName}*_R2.fastq"
#		Output Files
lablog="${outputDir}${sampleName}_assembly.log"

module load SPAdes-3.8.0
module load quast-4.1

echo -e "$(date)" 
echo -e "*********** ASSEMBLY $sampleName ************"

#	CREATE DIRECTORY FOR THE SAMPLE IF NECESSARY
if [ ! -d ${outputDir} ]
then
	mkdir -p $outputDir
	echo -e "${outputDir} created"
fi

#if [ ! -d "${outputDir}spades" ]
#then
#	mkdir -p "${outputDir}spades"
#	echo -e "${outputDir}spades created"
#fi

if [ ! -d "${outputDir}quast" ]
then
	mkdir -p "${outputDir}quast"
	echo -e "${outputDir}quast created"
fi



#	RUN SPADES	
echo -e "$(date)\t start running spades for ${sampleName} for ${organism}\n" > $lablog
echo -e "The command is: ### spades.py --phred-offset 33 -1 $mappedR1Fastq -2 $mappedR2Fastq --meta -o $outputDir" >> $lablog
spades.py --phred-offset 33 -1 $mappedR1Fastq -2 $mappedR2Fastq --meta -o ${outputDir} 2>&1 | tee -a $lablog
echo -e "$(date)\t finished running spades for ${sampleName} for ${organism}\n" >> $lablog

#	RUN QUAST
echo -e "$(date)\t start running quast for ${sampleName} for ${organism}\n" >> $lablog
echo -e "The command is ###  metaquast.py -f ${outputDir}/contigs.fasta -o ${outputDir}quast/" >> $lablog
metaquast.py -f ${outputDir}/contigs.fasta -o ${outputDir}quast/ 2>&1 | tee -a $lablog
echo -e "$(date)\t finished running quast for ${sampleName} for ${organism}\n" >> $lablog


}

#assemble /processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/ANALYSIS/Unai16/03.BACTERIA/
