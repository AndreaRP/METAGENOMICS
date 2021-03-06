#!/bin/bash
set -e
#########################################################
#	SCRIPT TO FILTER VIRUS READS USING BOWTIE2 MAPPING	#
#########################################################
# 1. Creates necessary directories. 
# 2. Maps against virus reference genome.
# 3. Generates fastq files using the bam generated by bowtie2 which contains only reads that mapped the virus reference.
# Note: This script should be run after filtering the host with host_removal.sh.

# Arguments:
# $1 (virDB) = Directory of parasite reference genome (REFERENCES/VIRUS_GENOME_REFERENCE/).
# $2 (sampleDir) = Directory containing noHost files. (ANALYSIS/04-noHost/sampleName/)

# Input Files: (In ANALYSIS/04-noHost/sampleName/)
# sampleName_noHost_R1.fastq: fastq file with the R1 reads of the sample after filtering the host.
# sampleName_noHost_R2.fastq: fastq file with the R2 reads of the sample after filtering the host.

# Output files: (In ANALYSIS/06-virus/sampleName/reads/)
# sampleName_virus_R1.fastq: .fastq file with R1 reads that mapped the virus DB.
# sampleName_virus_R2.fastq: .fastq file with R2 reads that mapped the virus DB.
# sampleName_virus_sorted.bam: sorted BAM file with the reads that mapped against the virus Whole Genome reference.
# sampleName_virus_sorted.bam.bai: index of the BAM file.
# sampleName_virus_mapping.log: .log file with a log of the mapping of virus virus DB.
# (sampleName_virus_mapped.sam: SAM file from mapping the processed files against virus Whole Genome reference. Intermediary file deleted on the run)
# (sampleName_virus_mapped.bam: BAM file from mapping the processed files against virus Whole Genome reference. Intermediary file deleted on the run)

source ./pikaVirus.config

function map_virus {
#	GET ARGUMENTS
sampleName=$1
#	INITIALIZE VARIABLES
#		Constants
virDBDir="${virDB}/WG/bwt2/virus_all"
virFilesDir="${analysisDir}/06-virus/${sampleName}/reads/" #directory where the host filtering files will we saved (sam for mapping and fastq for host free samples)
noHostDir="${analysisDir}/04-noHost/${sampleName}/" #directory where the host free reads are
 
#		Input Files
noHostR1Fastq="${noHostDir}${sampleName}_noHost_R1.fastq"
noHostR2Fastq="${noHostDir}${sampleName}_noHost_R2.fastq"
#		OutputFiles
bowtie2logFile="${virFilesDir}${sampleName}_virus_mapping.log"
VirMappedR1Fastq="${virFilesDir}${sampleName}_virus_R1.fastq"
VirMappedR2Fastq="${virFilesDir}${sampleName}_virus_R2.fastq"
mappedSamFile="${virFilesDir}${sampleName}_virus_mapped.sam"
mappedBamFile="${virFilesDir}${sampleName}_virus_mapped.bam" #bowtie bam file with the reads that mapped against the WG reference
sortedBamFile="${virFilesDir}${sampleName}_virus_sorted.bam" #bowtie bam file with the reads that mapped against the WG reference

# load programs in module (comment for local runs) 
#module load bowtie/bowtie2-2.2.5
#module load samtools/samtools-1.2

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
echo -e "The command is: ### bowtie2 -fr -x "$virDBDir" -q -1 $noHostR1Fastq -2 $noHostR2Fastq -S $mappedSamFile ###\n" >> $bowtie2logFile 
bowtie2 -a -fr -x "$virDBDir" -q -1 $noHostR1Fastq -2 $noHostR2Fastq -S $mappedSamFile 2>&1 | tee -a $bowtie2logFile
echo -e "$(date)\t Finished mapping ${sampleName}\n" >> $bowtie2logFile
echo -e "$(date)\t Converting SAM to BAM of ${sampleName} \n" >> $bowtie2logFile
samtools view -Sb $mappedSamFile > $mappedBamFile
rm $mappedSamFile
samtools sort -O bam -T temp -o $sortedBamFile $mappedBamFile
samtools index -b $sortedBamFile
rm $mappedBamFile
echo -e "$(date)\t Finished converting SAM to BAM of ${sampleName} \n" >> $bowtie2logFile

#	SEPARATE R1 AND R2 MAPPED READS AND FILTER HOST
echo -e "----------------- Filtering virus reads ...---------------------"
echo -e "$(date)\t Start filtering ${sampleName}\n" >> $bowtie2logFile
echo -e "The command is: ###samtools view -F 0x40 $sortedBamFile | awk '{if($3 != "*") print "@"$1"\n"$10"\n""+""\n"$11}' > $VirMappedR1Fastq" >> $bowtie2logFile
samtools view -F 0x40 $sortedBamFile | awk '{if($3 != "*") print "@" $1" \n" $10 "\n" "+" $1 "\n" $11}' > $VirMappedR1Fastq
echo -e "The command is: ###samtools view -f 0x40 $sortedBamFile | awk '{if($3 != "*") print "@"$1"\n"$10"\n""-""\n"$11}' > $VirMappedR2Fastq" >> $bowtie2logFile
samtools view -f 0x40 $sortedBamFile | awk '{if($3 != "*") print "@" $1" \n" $10 "\n" "+" $1 "\n" $11}' > $VirMappedR2Fastq
#	samtools separates R1 (-F) or R2 (-f) reads using the mapped BAM file and awk filters those mapped (=!"*") in fastq format
echo -e "$(date)\t Finished filtering ${sampleName}\n" >> $bowtie2logFile

echo -e "$(date)" 
echo -e "*********** FINISHED MAPPING VIRUS IN $sampleName ************"
}
