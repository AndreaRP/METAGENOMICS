#!/bin/bash
set -e

#                     _ _ _                           _             _ 
#    __ _ _   _  __ _| (_) |_ _   _    ___ ___  _ __ | |_ _ __ ___ | |
#   / _` | | | |/ _` | | | __| | | |  / __/ _ \| '_ \| __| '__/ _ \| |
#  | (_| | |_| | (_| | | | |_| |_| | | (_| (_) | | | | |_| | | (_) | |
#   \__, |\__,_|\__,_|_|_|\__|\__, |  \___\___/|_| |_|\__|_|  \___/|_|
#      |_|                    |___/                                   


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
#["$1"="--"] && shift
function showHelp {
	echo -e 'Usage: preprocessing -s <path_to_samples>'
	echo -e 'the path to samples must contain the fastq sequences. Tha file name must contain R1 or R2.'
	echo -e 'preprocessing -h: show this help'	
	exit 0
}

#	VARIABLES
#sampleAnalysisDir="${workingDir}ANALYSIS/01.fastqc/${sampleName}"
samplePreProQCDir="${workingDir}ANALYSIS/01-fastqc/${sampleName}"
samplePostProDir="${workingDir}ANALYSIS/02-preprocessing/${sampleName}"
samplePostProQCDir="${workingDir}ANALYSIS/03-preproQC/${sampleName}"
sampleStatsDir="${workingDir}ANALYSIS/99-stats/${sampleName}/"
rawDir="${workingDir}ANALYSIS/00-reads/"


module load FastQC-0.11.3
module load Trimmomatic-0.33

function makedir {

if [ ! -d "$1" ]
then
	mkdir -p "$1"
fi
}

function unzip-strip {
    local zip=$1
    local dest=${2:-.}
    local temp=$(mktemp -d) && unzip -d "$temp" "$zip" && mkdir -p "$dest" &&
          	    shopt -s dotglob && local f=("$temp"/*) &&
        	        if (( ${#f[@]} == 1 )) && [[ -d "${f[0]}" ]] ; then
         	        	mv "$temp"/*/* "$dest"
                    else
                    	mv "$temp"/* "$dest"
     	        	fi
     	        && rmdir "$temp"/* "$temp"
}

#	RAW reads FastQC

makedir $samplePreProQCDir

echo -e "$(date): Execute fastqc.sh" >> "${samplePreProQCDir}/${sampleName}_preProQC.log"
echo -e " Command is: ### find $rawDir -name "${sampleName}_*.fastq.gz" -exec fastqc {} --outdir $samplePreProQCDir \; ###" >> "${samplePreProQCDir}/${sampleName}_preProQC.log"
find $rawDir -name "${sampleName}_*.fastq.gz" -exec fastqc {} --outdir $samplePreProQCDir \; >> "${samplePreProQCDir}/${sampleName}_preProQC.log"
echo -e "$(date): Finish fastqc.sh" >> "${samplePreProQCDir}/${sampleName}_preProQC.log"
echo -e "$(date): ********* Finished quaility control **********" >> "${samplePreProQCDir}/${sampleName}_preProQC.log"

#	TRIMMOMMATIC QUALITY CONTROL

makedir $samplePostProDir
echo "sample name: ${sampleName}"
java -jar /opt/Trimmomatic-0.33/trimmomatic-0.33.jar PE -threads 10 -phred33 ${workingDir}/ANALYSIS/00-reads/${sampleName}_*_R1_*.fastq.gz ${workingDir}/ANALYSIS/00-reads/${sampleName}_*_R2_*.fastq.gz ${samplePostProDir}/${sampleName}_R1_paired.fastq ${samplePostProDir}/${sampleName}_R1_unpaired.fastq ${samplePostProDir}/${sampleName}_R2_paired.fastq ${samplePostProDir}/${sampleName}_R2_unpaired.fastq ILLUMINACLIP:/opt/Trimmomatic/adapters/NexteraPE-PE.fa:2:30:10 SLIDINGWINDOW:4:20 MINLEN:50 >> ${samplePostProDir}/${sampleName}_trimming.log

#	TRIMMED READS FASTQC

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
mv ${sampleStatsDir}${sampleName}*R1_paired*/ "${sampleStatsDir}${sampleName}_R1_filtered_fastqc/"
mv ${sampleStatsDir}${sampleName}*R2_paired*/ "${sampleStatsDir}${sampleName}_R2_filtered_fastqc/"
