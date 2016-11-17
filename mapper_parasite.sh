#!/bin/bash
set -e
#########################################################
#	SCRIPT TO FILTER protozoaS USING BOWTIE2 MAPPING	#
#########################################################
# 1. Creates necessary directories. 
# 2. Maps against protozoa reference genome.
# 3. Generates fastq files using the bam generated by bowtie2 which contains only reads that mapped the protozoa reference.
# 4. Maps against invertebrate reference genome.
# 5. Generates fastq files using the bam generated by bowtie2 which contains only reads that mapped the  reference.
# Note: This script should be run after filtering the host with host_removal.sh.

# Arguments:
# $1 (DB) = Directory of parasite reference genome (REFERENCES/).
# $2 (sampleDir) = Directory containing noHost files. (ANALYSIS/04-noHost/sampleName/)

# Input Files: (In ANALYSIS/04-noHost/sampleName/)
# sampleName_noHost_R1.fastq: fastq file with the R1 reads of the sample after filtering the host.
# sampleName_noHost_R2.fastq: fastq file with the R2 reads of the sample after filtering the host.

# Output files: (In ANALYSIS/08-protozoa/sampleName/reads/)
# sampleName_protozoa_R1.fastq: .fastq file with R1 reads that mapped the protozoa DB.
# sampleName_protozoa_R2.fastq: .fastq file with R2 reads that mapped the protozoa DB.
# sampleName_protozoa_sorted.bam: sorted BAM file with the reads that mapped against the protozoa Whole Genome reference.
# sampleName_protozoa_sorted.bam.bai: index of the BAM file.
# sampleName_protozoa_mapping.log: .log file with a log of the mapping of protozoa DB.
# (sampleName_protozoa_mapped.sam: SAM file from mapping the processed files against protozoa Whole Genome reference. Intermediary file deleted on the run)
# (sampleName_protozoa_mapped.bam: BAM file from mapping the processed files against protozoa Whole Genome reference. Intermediary file deleted on the run)

# Output files: (In ANALYSIS/09-invertebrate/sampleName/reads/)
# sampleName_invertebrate_R1.fastq: .fastq file with R1 reads that mapped the invertebrate DB.
# sampleName_invertebrate_R2.fastq: .fastq file with R2 reads that mapped the invertebrate DB.
# sampleName_invertebrate_sorted.bam: sorted BAM file with the reads that mapped against the invertebrate Whole Genome reference.
# sampleName_invertebrate_sorted.bam.bai: index of the BAM file.
# sampleName_invertebrate_mapping.log: .log file with a log of the mapping of invertebrate DB.
# (sampleName_invertebrate_mapped.sam: SAM file from mapping the processed files against invertebrate Whole Genome reference. Intermediary file deleted on the run)
# (sampleName_invertebrate_mapped.bam: BAM file from mapping the processed files against invertebrate Whole Genome reference. Intermediary file deleted on the run)

function map_parasite {
#	GET ARGUMENTS
DB=$1  
sampleDir=$2
#	INITIALIZE VARIABLES
#		Constants
sampleName=$(basename "${sampleDir}")
invertebrateDB="${DB}INVERTEBRATE_GENOME_REFERENCE/WG/bwt2/invertebrate_all"
protozoaDB="${DB}PROTOZOA_GENOME_REFERENCE/WG/bwt2/protozoa_all"
workingDir="/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/"
protozoaFilesDir="${workingDir}/ANALYSIS/08-protozoa/${sampleName}/reads/" #directory where the files will we saved (sam for mapping and fastq for mapped samples)
invertebrateFilesDir="${workingDir}/ANALYSIS/09-invertebrate/${sampleName}/reads/" #directory where the files will we saved (sam for mapping and fastq for mapped samples)
noHostDir="${workingDir}ANALYSIS/04-noHost/${sampleName}/" #directory where the host free samples are located
#		Input Files
noHostR1Fastq="${noHostDir}${sampleName}_noHost_R1.fastq" #R1 host free file
noHostR2Fastq="${noHostDir}${sampleName}_noHost_R2.fastq" #R2 host free file
#		Output Files: protozoa
mappedSamProtozoaFile="${protozoaFilesDir}${sampleName}_protozoa_mapped.sam" #bowtie sam file with the reads that mapped against the protozoa reference
mappedBamProtozoaFile="${protozoaFilesDir}${sampleName}_protozoa_mapped.bam" #bowtie bam file with the reads that mapped against the protozoa reference
sortedBamProtozoaFile="${protozoaFilesDir}${sampleName}_protozoa_sorted.bam" #sorted bowtie bam file with the reads that mapped against the protozoa reference
bowtie2logFileProtozoa="${protozoaFilesDir}${sampleName}_protozoa_mapping.log" #log of the mapping against the protozoa reference
protozoaMappedR1Fastq="${protozoaFilesDir}${sampleName}_protozoa_R1.fastq" #file with the R1 reads which mapped against protozoa reference
protozoaMappedR2Fastq="${protozoaFilesDir}${sampleName}_protozoa_R2.fastq" #file with the R2 reads which mapped against the protozoa reference
#		Output Files: invertebrate
mappedSamInvertebrateFile="${invertebrateFilesDir}${sampleName}_invertebrate_mapped.sam" #bowtie sam file with the reads that mapped against the invertebrate reference
mappedBamInvertebrateFile="${invertebrateFilesDir}${sampleName}_invertebrate_mapped.bam" #bowtie bam file with the reads that mapped against the invertebrate reference
sortedBamInvertebrateFile="${invertebrateFilesDir}${sampleName}_invertebrate_sorted.bam" #sorted bowtie bam file with the reads that mapped against the invertebrate reference
bowtie2logFileInvertebrate="${invertebrateFilesDir}${sampleName}_invertebrate_mapping.log" #log of the mapping against the invertebrate reference  
invertebrateMappedR1Fastq="${invertebrateFilesDir}${sampleName}_invertebrate_R1.fastq" #file with the R1 reads that mapped against the invertebrate reference
invertebrateMappedR2Fastq="${invertebrateFilesDir}${sampleName}_invertebrate_R2.fastq" #file with the R2 reads that mapped against the invertebrate reference

# load programs in module (comment for local runs) 
module load bowtie/bowtie2-2.2.4
module load samtools/samtools-1.2

echo -e "$(date)" 
echo -e "*********** MAPPING parasites IN $sampleName ************"
#	CREATE DIRECTORY FOR THE PROTOZOA IF NECESSARY
if [ ! -d ${protozoaFilesDir} ]
then
	mkdir -p $protozoaFilesDir
	echo -e "${protozoaFilesDir} created"
fi

#	CREATE DIRECTORY FOR THE INVERTEBRATE IF NECESSARY
if [ ! -d ${invertebrateFilesDir} ]
then
	mkdir -p $invertebrateFilesDir
	echo -e "${invertebrateFilesDir} created"
fi
################################################################################################	
#	BOWTIE2 MAPPING AGAINST protozoa	
echo -e "--------Bowtie2 is mapping against the protozoa reference ....------"
echo -e "$(date)\t Start mapping ${sampleName} to protozoa reference \n" > $bowtie2logFileProtozoa
echo -e "The command is: ### bowtie2 -fr -x "$protozoaDB" -q -1 $noHostR1Fastq -2 $noHostR2Fastq -S $mappedSamProtozoaFile ###\n" >> $bowtie2logFileProtozoa 
bowtie2 -a -fr -x "$protozoaDB" -q -1 $noHostR1Fastq -2 $noHostR2Fastq -S $mappedSamProtozoaFile 2>&1 | tee -a $bowtie2logFileProtozoa
echo -e "$(date)\t Finished mapping ${sampleName} against protozoa reference \n" >> $bowtie2logFileProtozoa
echo -e "$(date)\t Converting SAM to BAM of ${sampleName} \n" >> $bowtie2logFileProtozoa
samtools view -Sb $mappedSamProtozoaFile > $mappedBamProtozoaFile
rm $mappedSamProtozoaFile
samtools sort -O bam -T temp -o $sortedBamProtozoaFile $mappedBamProtozoaFile
samtools index -b $sortedBamProtozoaFile
rm $mappedBamProtozoaFile
echo -e "$(date)\t Finished converting SAM to BAM of ${sampleName} \n" >> $bowtie2logFileProtozoa

#	SEPARATE AND EXTRACT R1 AND R2 READS MAPPED TO protozoa 
echo -e "----------------- Filtering protozoa reads that mapped to reference ...---------------------"
echo -e "$(date)\t Start filtering ${sampleName} reads that mapped to protozoa \n" >> $bowtie2logFileProtozoa
echo -e "The command is: ###samtools view -F 0x40 $sortedBamProtozoaFile | awk '{if($3 != '*') print '@' $1 '\\n' $10 '\\n' '+' '\\n' $11}' > $protozoaMappedR1Fastq" >> $bowtie2logFileProtozoa
samtools view -F 0x40 $sortedBamProtozoaFile | awk '{if($3 != "*") print "@" $1 "\n" $10 "\n" "+" $1 "\n" $11}' > $protozoaMappedR1Fastq
echo -e "The command is: ###samtools view -f 0x40 $sortedBamProtozoaFile | awk '{if($3 != '*') print '@' $1 '\\n' $10 '\\n' '-' '\\n' $11}' > $protozoaMappedR2Fastq" >> $bowtie2logFileProtozoa
samtools view -f 0x40 $sortedBamProtozoaFile | awk '{if($3 != "*") print "@" $1 "\n" $10 "\n" "+" $1 "\n" $11}' > $protozoaMappedR2Fastq
#	samtools separates R1 (-F) or R2 (-f) reads using the mapped SAM file and awk filters those mapped (=!"*") in fastq format
echo -e "$(date)\t Finished filtering ${sampleName} reads that mapped to protozoa \n" >> $bowtie2logFileProtozoa

################################################################################################	
#	BOWTIE2 MAPPING AGAINST Invertebrate	
echo -e "--------Bowtie2 is mapping against the Invertebrate reference ....------"
echo -e "$(date)\t Start mapping ${sampleName} to Invertebrate reference \n" > $bowtie2logFileInvertebrate
echo -e "The command is: ### bowtie2 -fr -x "$invertebrateDB" -q -1 $noHostR1Fastq -2 $noHostR2Fastq -S $mappedSamInvertebrateFile ###\n" >> $bowtie2logFileInvertebrate 
bowtie2 -a -fr -x "$invertebrateDB" -q -1 $noHostR1Fastq -2 $noHostR2Fastq -S $mappedSamInvertebrateFile 2>&1 | tee -a $bowtie2logFileInvertebrate
echo -e "$(date)\t Finished mapping ${sampleName} against Invertebrate reference \n" >> $bowtie2logFileInvertebrate
echo -e "$(date)\t Converting SAM to BAM of ${sampleName} \n" >> $bowtie2logFileInvertebrate
samtools view -Sb $mappedSamInvertebrateFile > $mappedBamInvertebrateFile
rm $mappedSamInvertebrateFile
samtools sort -O bam -T temp -o $sortedBamInvertebrateFile $mappedBamInvertebrateFile
samtools index -b $sortedBamInvertebrateFile
rm $mappedBamInvertebrateFile
echo -e "$(date)\t Finished converting SAM to BAM of ${sampleName} \n" >> $bowtie2logFileInvertebrate

#	SEPARATE AND EXTRACT R1 AND R2 READS MAPPED TO Invertebrate 
echo -e "----------------- Filtering Invertebrate reads that mapped to reference ...---------------------"
echo -e "$(date)\t Start filtering ${sampleName} reads that mapped to Invertebrate \n" >> $bowtie2logFileInvertebrate
echo -e "The command is: ###samtools view -F 0x40 $sortedBamInvertebrateFile | awk '{if($3 != '*') print '@' $1 '\\n' $10 '\\n' '+' '\\n' $11}' > $invertebrateMappedR1Fastq" >> $bowtie2logFileInvertebrate
samtools view -F 0x40 $sortedBamInvertebrateFile | awk '{if($3 != "*") print "@" $1 "\n" $10 "\n" "+" $1 "\n" $11}' > $invertebrateMappedR1Fastq
echo -e "The command is: ###samtools view -f 0x40 $sortedBamInvertebrateFile | awk '{if($3 != '*') print '@' $1 '\\n' $10 '\\n' '-' '\\n' $11}' > $invertebrateMappedR2Fastq" >> $bowtie2logFileInvertebrate
samtools view -f 0x40 $sortedBamInvertebrateFile | awk '{if($3 != "*") print "@" $1 "\n" $10 "\n" "+" $1 "\n" $11}' > $invertebrateMappedR2Fastq
#	samtools separates R1 (-F) or R2 (-f) reads using the mapped SAM file and awk filters those mapped (=!"*") in fastq format
echo -e "$(date)\t Finished filtering ${sampleName} reads that mapped to Invertebrate \n" >> $bowtie2logFileInvertebrate


################################################################################################	
echo -e "$(date)" 
echo -e "*********** FINISHED MAPPING protozoa IN $sampleName ************"
}

