#!/bin/bash
set -e
#########################################################
#	SCRIPT TO REMOVE HOST READS USING BOWTIE2 MAPPING	#
#########################################################

# 1. Creates necessary directories. 
# 2. Maps against host reference genome.
# 3. Creates fastq files using the bam generated by bowtie2 which contains only non-host reads
# Note: This script must be run after performing quality control and trimming with preprocessing.sh.

# Arguments:
# $1 (hostDB) = Directory of host reference genome (REFERENCES/HOST_GENOME_REFERENCE/).
# $2 (sampleName) = Name of the sample to be processed. Must match the name of the sample in the RAW directory.

# Input Files: (In ANALYSIS/02-preprocessing/sampleName/)
# sampleR1: fastq file with the R1 reads of the sample after trimming.
# sampleR2: fastq file with the R2 reads of the sample after trimming.

# Output files: (In ANALYSIS/04-noHost/sampleName/)
# sampleName_sorted.bam: BAM file from mapping the processed reads against the host genome. This file does NOT contain host reads.
# sampleName_sorted.bam.bai: index file of the sorted bam.
# sampleName_noHost_R1.fastq: fastq file with all the R1 reads that where NOT mapped against the host genome. 
# sampleName_noHost_R2.fastq: fastq file with all the R2 reads that where NOT mapped against the host genome. 
# sampleName_host_removal.log: .log file with a log of the mapping.
# (sampleName_mapped_sam: sam file of reads mapped to the host reference. Intermediary file deleted on the run) 
# (sampleName_mapped_bam: bam file of reads mapped to the host reference. Intermediary file deleted on the run) 

source ./pikaVirus.config

function removeHost {
#	GET ARGUMENTS 
sampleDir=$2

#	INITIALIZE VARIABLES
# Constants
hostDB="${hostDB}WG/bwt2/hg38.AnalysisSet"
sampleName=$(basename "${sampleDir}")
#workingDir="/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/"
preprocessedFilesDir="${analysisDir}/02-preprocessing/${sampleName}/" # directory where the preprocessed files are.
noHostFilesDir="${analysisDir}/04-noHost/${sampleName}/" #directory where the host filtering files will we saved (sam for mapping and fastq for host free samples)
# Input Files
sampleR1="${preprocessedFilesDir}${sampleName}_R1_paired.fastq"
sampleR2="${preprocessedFilesDir}${sampleName}_R2_paired.fastq"
# Output Files
mappedSamFile="${noHostFilesDir}${sampleName}_mapped.sam"
mappedBamFile="${noHostFilesDir}${sampleName}_mapped.bam"
sortedBamFile="${noHostFilesDir}${sampleName}_sorted.bam"
bowtie2logFile="${noHostFilesDir}${sampleName}_host_removal.log"
mappedR1Fastq="${noHostFilesDir}${sampleName}_noHost_R1.fastq"
mappedR2Fastq="${noHostFilesDir}${sampleName}_noHost_R2.fastq"

# load programs in module (comment for local runs) 
#module load bowtie/bowtie2-2.2.4
#module load samtools/samtools-1.2

echo -e "$(date)" 
echo -e "*********** REMOVING HOST FROM $sampleName ************"

#	CREATE DIRECTORY FOR THE SAMPLE IF NECESSARY
if [ ! -d ${noHostFilesDir} ]
then
	mkdir -p $noHostFilesDir
	echo -e "${noHostFilesDir} created"
fi
	
#	BOWTIE2 MAPPING AGAINST HOST
echo -e "--------Bowtie2 is mapping against the reference genome....------"
echo -e "$(date)\t Start mapping ${sampleName}\n" > $bowtie2logFile
echo -e "The command is: ### bowtie2 -fr -x "$hostDB" -q -1 $sampleR1 -2 $sampleR2 -S $mappedSamFile ###\n" >> $bowtie2logFile 
bowtie2 -fr -x "$hostDB" -q -1 $sampleR1 -2 $sampleR2 -S $mappedSamFile 2>&1 | tee -a $bowtie2logFile
echo -e "$(date)\t Finished mapping ${sampleName}\n" >> $bowtie2logFile
echo -e "$(date)\t Converting SAM to BAM of ${sampleName} \n" >> $bowtie2logFile
samtools view -Sb $mappedSamFile > $mappedBamFile
rm $mappedSamFile
samtools sort -O bam -T $sortedBamFile -o $sortedBamFile $mappedBamFile 2>&1 | tee -a $bowtie2logFile
samtools index -b $sortedBamFile
rm $mappedBamFile
echo -e "$(date)\t Finished converting SAM to BAM of ${sampleName} \n" >> $bowtie2logFile

#	SEPARATE R1 AND R2 MAPPED READS AND FILTER HOST
echo -e "-----------------Filtering non-host reads...---------------------"
echo -e "$(date)\t Start filtering ${sampleName}\n" >> $bowtie2logFile
echo -e "The command is: ###samtools view -F 0x40 $sortedBamFile | awk '{if($3 == '*') print "@"$1'\\n'$10'\\n''+''\\n'$11}' > $mappedR1Fastq" >> $bowtie2logFile
samtools view -F 0x40 $sortedBamFile | awk '{if($3 == "*") print "@" $1 "\n" $10 "\n" "+" $1 "\n" $11}' > $mappedR1Fastq
echo -e "The command is: ###samtools view -f 0x40 $sortedBamFile | awk '{if($3 == '*') print '@'$1'\\n'$10'\\n''-''\\n'$11}' > $mappedR2Fastq" >> $bowtie2logFile
samtools view -f 0x40 $sortedBamFile | awk '{if($3 == "*") print "@" $1 "\n" $10 "\n" "+" $1 "\n" $11}' > $mappedR2Fastq
#	samtools separates R1 (-F) or R2 (-f) reads using the sorted BAM file and awk filters those not mapped (="*") in fastq format
echo -e "$(date)\t Finished filtering ${sampleName}\n" >> $bowtie2logFile

}

