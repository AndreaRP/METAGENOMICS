#!/bin/bash
set -e
#########################################################
#	SCRIPT TO FILTER BAC READS USING BOWTIE2 MAPPING	#
#########################################################
# Arguments:
# $1 = bacDB. File with the reference genome for the mapping. Contains the references.
# $2 = sampleName. Name of the sample to be processed. Must match the name of the sample in the RAW directory.
# 1. Creates necessary directories. 
# 2. Maps against bacteria reference genome.
# 3. Creates .fastq files using the host-free files generated by host_removal.sh
# Output files: (In ANALYSIS/sampleName/03.BACTERIA/)
# sampleName_xx_bacteria_mapped.sam: SAM file from mapping the processed files against xx reference genome.
# sampleName_xx_bacteria_mapped.bam: BAM file from mapping the processed files against xx reference genome.
# sampleName_xx_Bacteria_R1.fastq: .fastq file with R1 reads that mapped the bacteria xx DB.
# sampleName_xx_Bacteria_R2.fastq: .fastq file with R2 reads that mapped the bacetria xx DB.
# sampleName_xx_bacteria_mapping.log: .log file with a log of the mapping of xx DB.

function map_bacteria {
#	GET ARGUMENTS
bacDB=$1  
sampleAnalysisDir=$2
#	INITIALIZE VARIABLES
#		Directories
sampleName=$(basename "${sampleAnalysisDir}")
bac16SDB="${bacDB}16S/bwt2/16S"
bacWGDB="${bacDB}WG/bwt2/WG"
bacFilesDir="${sampleAnalysisDir}/03.BACTERIA/" #directory where the files will we saved (sam for mapping and fastq for mapped samples)
noHostDir="${sampleAnalysisDir}/02.HOST/" #directory where the host free samples are located
#		Input Files
noHostR1Fastq="${noHostDir}${sampleName}_noHost_R1.fastq" #R1 host free file
noHostR2Fastq="${noHostDir}${sampleName}_noHost_R2.fastq" #R2 host free file
#		OutputFiles: 16S
mappedSam16SFile="${bacFilesDir}${sampleName}_bacteria_mapped_16S.sam" #bowtie sam file with the reads that mapped against the 16S reference
mappedBam16SFile="${bacFilesDir}${sampleName}_bacteria_mapped_16S.bam" #bowtie bam file with the reads that mapped against the 16S reference
sortedBam16SFile="${bacFilesDir}${sampleName}_bacteria_sorted_16S.bam"
bowtie2logFile16S="${bacFilesDir}${sampleName}_bacteria_mapping_16S.log" #log of the mapping against the 16S reference
BacMappedR116SFastq="${bacFilesDir}${sampleName}_bacteria_R1_16S.fastq" #file with the R1 reads which mapped against 16S reference
BacMappedR216SFastq="${bacFilesDir}${sampleName}_bacteria_R2_16S.fastq" #file with the R2 reads which mapped against the 16S reference
#		OutputFiles: Whole Genome (WG)
mappedSamWGFile="${bacFilesDir}${sampleName}_WG_bacteria_mapped.sam" #bowtie sam file with the reads that mapped against the WG reference
mappedBamWGFile="${bacFilesDir}${sampleName}_WG_bacteria_mapped.bam" #bowtie bam file with the reads that mapped against the WG reference
sortedBamWGFile="${bacFilesDir}${sampleName}_WG_bacteria_sorted.bam"
bowtie2logFileWG="${bacFilesDir}${sampleName}_WG_bacteria_mapping.log" #log of the mapping against the WG reference  
BacMappedR1WGFastq="${bacFilesDir}${sampleName}_WG_bacteria_R1.fastq" #file with the R1 reads that mapped against the WG reference
BacMappedR2WGFastq="${bacFilesDir}${sampleName}_WG_bacteria_R2.fastq" #file with the R2 reads that mapped against the WG reference

module load bowtie/bowtie2-2.2.4
module load samtools/samtools-1.2

echo -e "$(date)" 
echo -e "*********** MAPPING BACTERIA IN $sampleName ************"

#	CREATE DIRECTORY FOR THE SAMPLE IF NECESSARY
if [ ! -d ${bacFilesDir} ]
then
	mkdir -p $bacFilesDir
	echo -e "${bacFilesDir} created"
fi
################################################################################################	
#	BOWTIE2 MAPPING AGAINST BACTERIA 16S	
echo -e "--------Bowtie2 is mapping against the 16S reference ....------"
echo -e "$(date)\t Start mapping ${sampleName} to 16S reference \n" > $bowtie2logFile16S
echo -e "The command is: ### bowtie2 -fr -x "$bac16SDB" -q -1 $noHostR1Fastq -2 $noHostR2Fastq -S $mappedSam16SFile ###\n" >> $bowtie2logFile16S 
bowtie2 -fr -x "$bac16SDB" -q -1 $noHostR1Fastq -2 $noHostR2Fastq -S $mappedSam16SFile 2>&1 | tee -a $bowtie2logFile16S
echo -e "$(date)\t Finished mapping ${sampleName} against 16S reference \n" >> $bowtie2logFile16S
echo -e "$(date)\t Converting SAM to BAM of ${sampleName} \n" >> $bowtie2logFile16S
samtools view -Sb $mappedSam16SFile > $mappedBam16SFile
rm $mappedSam16SFile
samtools sort -O bam -T temp -o $sortedBam16SFile $mappedBam16SFile
samtools index -b $sortedBam16SFile
rm $mappedBam16SFile
echo -e "$(date)\t Finished converting SAM to BAM of ${sampleName} \n" >> $bowtie2logFile16S

#	SEPARATE AND EXTRACT R1 AND R2 READS MAPPED TO 16S 
echo -e "----------------- Filtering bacteria reads that mapped to 16S ...---------------------"
echo -e "$(date)\t Start filtering ${sampleName} reads that mapped to 16S \n" >> $bowtie2logFile16S
echo -e "The command is: ###samtools view -F 0x40 $sortedBam16SFile | awk '{if($3 != '*') print '@' $1 '\\n' $10 '\\n' '+' '\\n' $11}' > $BacMappedR116SFastq" >> $bowtie2logFile16S
samtools view -F 0x40 $sortedBam16SFile | awk '{if($3 != "*") print "@" $1 "\n" $10 "\n" "+" $1 "\n" $11}' > $BacMappedR116SFastq
echo -e "The command is: ###samtools view -f 0x40 $sortedBam16SFile | awk '{if($3 != '*') print '@' $1 '\\n' $10 '\\n' '+' '\\n' $11}' > $BacMappedR216SFastq" >> $bowtie2logFile16S
samtools view -f 0x40 $sortedBam16SFile | awk '{if($3 != "*") print "@" $1 "\n" $10 "\n" "+" $1 "\n" $11}' > $BacMappedR216SFastq
#	samtools separates R1 (-F) or R2 (-f) reads using the mapped SAM file and awk filters those mapped (=!"*") in fastq format
echo -e "$(date)\t Finished filtering ${sampleName} reads that mapped to 16S \n" >> $bowtie2logFile16S

################################################################################################	
#	BOWTIE2 MAPPING AGAINST BACTERIA WG	
echo -e "--------Bowtie2 is mapping against bacteria WG reference ....------"
echo -e "$(date)\t Start mapping ${sampleName} reads to bacteria WG reference \n" > $bowtie2logFileWG
echo -e "The command is: ### bowtie2 -fr -x "$bacWGDB" -q -1 $noHostR1Fastq -2 $noHostR2Fastq -S $mappedSamWGFile ###\n" >> $bowtie2logFileWG 
bowtie2 -fr -x "$bacWGDB" -q -1 $noHostR1Fastq -2 $noHostR2Fastq -S $mappedSamWGFile 2>&1 | tee -a $bowtie2logFileWG
echo -e "$(date)\t Finished mapping ${sampleName} reads to bacteria WG reference \n" >> $bowtie2logFileWG
echo -e "$(date)\t Converting SAM to BAM of ${sampleName} \n" >> $bowtie2logFileWG
samtools view -Sb $mappedSamWGFile > $mappedBamWGFile
rm $mappedSamWGFile
samtools sort -O bam -T temp -o $sortedBamWGFile $mappedBamWGFile
samtools index -b $sortedBamWGFile
rm $mappedBamWGFile
echo -e "$(date)\t Finished converting SAM to BAM of ${sampleName} \n" >> $bowtie2logFileWG

#	SEPARATE AND EXTRACT R1 AND R2 READS MAPPED TO WG 
echo -e "----------------- Filtering bacteria reads that mapped to bacteria WG reference ...---------------------"
echo -e "$(date)\t Start filtering ${sampleName} reads that mapped to bacteria WG \n" >> $bowtie2logFileWG
echo -e "The command is: ###samtools view -F 0x40 $sortedBamWGFile | awk '{if($3 != '*') print '@' $1 '\\n' $10 '\\n' '+' '\\n' $11}' > $BacMappedR1WGFastq" >> $bowtie2logFileWG
samtools view -F 0x40 $sortedBamWGFile | awk '{if($3 != "*") print "@" $1 "\n" $10 "\n" "+" $1 "\n" $11}' > $BacMappedR1WGFastq
echo -e "The command is: ###samtools view -f 0x40 $sortedBamWGFile | awk '{if($3 != '*') print '@' $1 '\\n' $10 '\\n' '-' '\\n' $11}' > $BacMappedR2WGFastq" >> $bowtie2logFileWG
samtools view -f 0x40 $sortedBamWGFile | awk '{if($3 != "*") print "@" $1 "\n" $10 "\n" "+" $1 "\n" $11}' > $BacMappedR2WGFastq
#	samtools separates R1 (-F) or R2 (-f) reads using the mapped SAM file and awk filters those mapped (=!"*") in fastq format
echo -e "$(date)\t Finished filtering ${sampleName} reads that mapped to bacteria WG reference \n" >> $bowtie2logFileWG

################################################################################################	
echo -e "$(date)" 
echo -e "*********** FINISHED MAPPING BACTERIA IN $sampleName ************"
}

#module load samtools/samtools-1.2
#map_bacteria /processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/REFERENCES/BACTERIA_GENOME_REFERENCE/ /processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/ANALYSIS/MuestraPrueba/
