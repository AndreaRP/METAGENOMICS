#!/bin/bash
set -e

#########################################################
#		  			PREPROCESSING SCRIPT			 	#
#########################################################
# 1. Creates necessary directories. 
# 2. Runs quality control of the raw reads with fastQC.
# 3. Performs quality trimming with Trimmommatic.
# 4. Runs quality control of the trimmed reads with fastQC
# 5. Prepares directory structure to create unified quality report

# Parameters:
# -s sampleName = Name of the sample
# -h = shows help

# Input Directory:
# rawDir= Directory where the raw reads are located (ANALYSIS/00-reads/)

# Input files: (In rawDir)
# sampleName_*_R1_*.fastq.gz
# sampleName_*_R2_*.fastq.gz

# Output Directories:
# samplePreProQCDir = Raw reads quality analysis directory. (ANALYSIS/01-fastqc/sampleName)
# 	Output files: (In samplePreProQCDir)
#	sampleName_*_R1_*.fastqc.html: HTML file with the quality report for R1 raw reads.
#	sampleName_*_R2_*.fastqc.html: HTML file with the quality report for R2 raw reads.
#	sampleName_*_R1_*.fastqc.zip: compressed file with the quality report files for R1 raw reads generated by fastQC.
#	sampleName_*_R2_*.fastqc.zip: compressed file with the quality report files for R2 raw reads generated by fastQC.
#	sampleName_preQC.log: log file for the quality analysis.
# samplePostProDir = Trimmed reads directory. (ANALYSIS/02-preprocessing/sampleName)
# 	Output files: (In samplePostProDir)
#	sampleName_R1_paired.fastq: fastq file with R1 trimmed paired reads.
#	sampleName_R2_paired.fastq: fastq file with R2 trimmed paired reads.
#	sampleName_R1_unpaired.fastq: fastq file with R1 trimmed unpaired reads.
#	sampleName_R2_unpaired.fastq: fastq file with R2 trimmed unpaired reads.
#	sampleName_postQC.log: log of the trimming process.
#	Note: Only the paired reads are used in the rest of the analysis
# samplePostProQCDir = Trimmed reads quality analysis directory. (ANALYSIS/03-preproQC/sampleName)
# 	Output files: (In samplePostProQCDir)
#	sampleName_R1_paired.fastqc.html: HTML file with the quality report for R1 trimmed reads.
#	sampleName_R2_paired.fastqc.html: HTML file with the quality report for R2 trimmed reads.
#	sampleName_R1_paired.fastqc.zip: compressed file with the quality report files for R1 trimmed reads generated by fastQC.
#	sampleName_R2_paired.fastqc.zip: compressed file with the quality report files for R2 trimmed reads generated by fastQC.
#	sampleName_postQC.log: log file for the quality analysis.
# sampleStatsDir = Quality report html directory. (ANALYSIS/99-stats/sampleName)



#	GLOBAL VARIABLES
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/' 

#	AWESOME SCRIPT
echo -e "PIPELINE START: $(date)"

#	Get parameters:
sampleName=''
while getopts "hs:" opt
do
	case "$opt" in
	h)	showHelp
		;;
	s)	sampleName=$OPTARG
		;;
	esac
done
shift $((OPTIND-1))


function showHelp {
	echo -e 'Usage: preprocessing -s <path_to_samples>'
	echo -e 'the path to samples must contain the fastq sequences. Tha file name must contain R1 or R2.'
	echo -e 'preprocessing -h: show this help'	
	exit 0
}

#	VARIABLES
samplePreProQCDir="${workingDir}ANALYSIS/01-fastqc/${sampleName}"
samplePostProDir="${workingDir}ANALYSIS/02-preprocessing/${sampleName}"
samplePostProQCDir="${workingDir}ANALYSIS/03-preproQC/${sampleName}"
sampleStatsDir="${workingDir}ANALYSIS/99-stats/${sampleName}/"
rawDir="${workingDir}ANALYSIS/00-reads/"


# load programs in module (comment for local runs) 
module load FastQC-0.11.3
module load Trimmomatic-0.33

function makedir {

if [ ! -d "$1" ]
then
	mkdir -p "$1"
fi
}

# CREATE DIRECTORY
makedir $samplePreProQCDir

# RAW READS QUALITY CONTROL
echo -e "$(date): Execute fastqc.sh" >> "${samplePreProQCDir}/${sampleName}_preProQC.log"
echo -e " Command is: ### find $rawDir -name "${sampleName}_*.fastq.gz" -exec fastqc {} --outdir $samplePreProQCDir \; ###" >> "${samplePreProQCDir}/${sampleName}_preProQC.log"
find $rawDir -name "${sampleName}_*.fastq.gz" -exec fastqc {} --outdir $samplePreProQCDir \; >> "${samplePreProQCDir}/${sampleName}_preProQC.log"
echo -e "$(date): Finish fastqc.sh" >> "${samplePreProQCDir}/${sampleName}_preProQC.log"
echo -e "$(date): ********* Finished quaility control **********" >> "${samplePreProQCDir}/${sampleName}_preProQC.log"

# TRIMMOMMATIC QUALITY CONTROL

makedir $samplePostProDir
echo "sample name: ${sampleName}"
java -jar /opt/Trimmomatic-0.33/trimmomatic-0.33.jar PE -threads 10 -phred33 ${workingDir}/ANALYSIS/00-reads/${sampleName}_*_R1_*.fastq.gz ${workingDir}/ANALYSIS/00-reads/${sampleName}_*_R2_*.fastq.gz ${samplePostProDir}/${sampleName}_R1_paired.fastq ${samplePostProDir}/${sampleName}_R1_unpaired.fastq ${samplePostProDir}/${sampleName}_R2_paired.fastq ${samplePostProDir}/${sampleName}_R2_unpaired.fastq ILLUMINACLIP:/opt/Trimmomatic/adapters/NexteraPE-PE.fa:2:30:10 SLIDINGWINDOW:4:20 MINLEN:50 >> ${samplePostProDir}/${sampleName}_trimming.log

# TRIMMED READS QUALITY CONTROL

makedir $samplePostProQCDir

echo -e "$(date): Execute fastqc.sh" >> "${samplePostProDir}/${sampleName}_postQC.log"
find $samplePostProDir -name "*_paired.fastq" -exec fastqc {} --outdir $samplePostProQCDir \; >> "${samplePostProQCDir}/${sampleName}_postQC.log"
echo -e "$(date): Finish fastqc.sh" >> "${samplePostProQCDir}/${sampleName}_postQC.log"
echo -e "$(date): ********* Finished quaility control **********" >> "${samplePostProQCDir}/${sampleName}_postQC.log"

#	CREATE REPORT

makedir $sampleStatsDir

# copy fastqc files to 99-stats (y le cambio el nombre)
find $samplePreProQCDir -name "*.zip" -exec unzip {} -d ${sampleStatsDir} \; 
# change name of folder
mv ${sampleStatsDir}${sampleName}*R1*/ "${sampleStatsDir}${sampleName}_prePro_R1_fastqc/"
mv ${sampleStatsDir}${sampleName}*R2*/ "${sampleStatsDir}${sampleName}_prePro_R2_fastqc/"

# copy fastqc files to 99-stats (y le cambio el nombre)
find $samplePostProQCDir -name "*_paired_fastqc.zip" -exec unzip {} -d ${sampleStatsDir} \; 
# change name of folder
mv ${sampleStatsDir}${sampleName}*R1_paired*/ "${sampleStatsDir}${sampleName}_trimmed_R1_fastqc/"
mv ${sampleStatsDir}${sampleName}*R2_paired*/ "${sampleStatsDir}${sampleName}_trimmed_R2_fastqc/"
