#!/bin/bash
set -e
#########################################################
#	SCRIPT TO FILTER VIR READS USING BOWTIE2 MAPPING	#
#########################################################
# Arguments:
# $1 = virDB. File with the reference genome for the mapping. Must be adjacent to the bowtie index files.
# $2 = sampleName. Name of the sample to be processed. Must match the name of the sample in the RAW directory.
# 1. Creates necessary directories. 
# 2. Maps against bacteria reference genome.
# 3. Creates .fastq files using the host-free files generated by host_removal.sh
# Output files: (In ANALYSIS/sampleName/04.VIRUS/)
# sampleName_virus_mapped.sam: SAM file from mapping the processed files against the reference genome.
# sampleName_Virus_R1.fastq: .fastq file with R1 reads that mapped the virus DB.
# sampleName_Virus_R2.fastq: .fastq file with R2 reads that mapped the virus DB.
# sampleName_virus_mapping.log: .log file with a log of the mapping.

function map_virus {
#	GET ARGUMENTS
virDB=$1  
sampleAnalysisDir=$2
#	INITIALIZE VARIABLES
#		Directories
sampleName=$(basename "${sampleAnalysisDir}")
virFilesDir="${sampleAnalysisDir}/04.VIRUS/" #directory where the host filtering files will we saved (sam for mapping and fastq for host free samples)
noHostDir="${sampleAnalysisDir}/02.HOST/"
#		Input Files
noHostR1Fastq="${noHostDir}${sampleName}_noHost_R1.fastq"
noHostR2Fastq="${noHostDir}${sampleName}_noHost_R2.fastq"
#		OutputFiles
bowtie2logFile="${virFilesDir}${sampleName}_virus_mapping.log"
VirMappedR1Fastq="${virFilesDir}${sampleName}_Virus_R1.fastq"
VirMappedR2Fastq="${virFilesDir}${sampleName}_Virus_R2.fastq"
mappedSamFile="${virFilesDir}${sampleName}_virus_mapped.sam"

echo -e "$(date)" 
echo -e "*********** MAPPING VIRUS IN $sampleName ************"

#	CREATE DIRECTORY FOR THE SAMPLE IF NECESSARY
if [ ! -d ${virFilesDir} ]
then
	mkdir -p $virFilesDir
	echo -e "${virFilesDir} created"
fi
	
#	BOWTIE2 MAPPING AGAINST VIRUS
echo -e "--------Bowtie2 is mapping against the reference ....------"
echo -e "$(date)\t Start mapping ${sampleName}\n" > $bowtie2logFile
echo -e "The command is: ### bowtie2 -fr -x "$virDB" -q -1 $noHostR1Fastq -2 $noHostR2Fastq -S $mappedSamFile ###\n" >> $bowtie2logFile 
bowtie2 -fr -x "$virDB" -q -1 $noHostR1Fastq -2 $noHostR2Fastq -S $mappedSamFile 2>&1 | tee -a $bowtie2logFile
echo -e "$(date)\t Finished mapping ${sampleName}\n" >> $bowtie2logFile

#	SEPARATE R1 AND R2 MAPPED READS AND FILTER HOST
echo -e "----------------- Filtering virus reads ...---------------------"
echo -e "$(date)\t Start filtering ${sampleName}\n" >> $bowtie2logFile
#echo -e "The command is: ###samtools view -F 0x40 $mappedSamFile | awk '{if($3 =! "*") print "@"$1"\n"$10"\n""+"$1"\n"$11}' > $VirMappedR1Fastq" >> $bowtie2logFile
echo -e "The command is: ###samtools view -F 0x40 $mappedSamFile | awk '{if($3 != "*") print "@"$1"\n"$10"\n""+""\n"$11}' > $VirMappedR1Fastq" >> $bowtie2logFile
samtools view -F 0x40 $mappedSamFile | awk '{if($3 != "*") print "@" $1 "\n" $10 "\n" "+" $1 "\n" $11}' > $VirMappedR1Fastq
echo -e "The command is: ###samtools view -f 0x40 $mappedSamFile | awk '{if($3 != "*") print "@"$1"\n"$10"\n""-""\n"$11}' > $VirMappedR2Fastq" >> $bowtie2logFile
samtools view -f 0x40 $mappedSamFile | awk '{if($3 != "*") print "@" $1" \n "$10 "\n" "+" $1 "\n" $11}' > $VirMappedR2Fastq
#	samtools separates R1 (-F) or R2 (-f) reads using the mapped SAM file and awk filters those mapped (=!"*") in fastq format
echo -e "$(date)\t Finished filtering ${sampleName}\n" >> $bowtie2logFile

echo -e "$(date)" 
echo -e "*********** FINISHED MAPPING VIRUS IN $sampleName ************"
}
