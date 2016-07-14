#!/bin/bash
set -e
#########################################################
#	SCRIPT TO FILTER PARASITES USING BOWTIE2 MAPPING	#
#########################################################
# Arguments:
# $1 = parasiteDB. File with the reference genome for the mapping. Contains the references.
# $2 = sampleName. Name of the sample to be processed. Must match the name of the sample in the RAW directory.
# 1. Creates necessary directories. 
# 2. Maps against parasite reference genome.
# 3. Creates .fastq files using the host-free files generated by host_removal.sh
# Output files: (In ANALYSIS/sampleName/06.PARASITE/)
# sampleName_xx_parasite_mapped.sam: SAM file from mapping the processed files against xx reference genome.
# sampleName_xx_parasite_R1.fastq: .fastq file with R1 reads that mapped the parasite xx DB.
# sampleName_xx_parasite_R2.fastq: .fastq file with R2 reads that mapped the parasiteetria xx DB.
# sampleName_xx_parasite_mapping.log: .log file with a log of the mapping of xx DB.

function map_parasite {
#	GET ARGUMENTS
parasiteDB=$1  
sampleAnalysisDir=$2
#	INITIALIZE VARIABLES
#		Directories
sampleName=$(basename "${sampleAnalysisDir}")
parasiteinvertebrateDB="${parasiteDB}INVERTEBRATE_GENOME_REFERENCE/WG/bwt2/invertebrate_all"
parasiteprotozoaDB="${parasiteDB}PROTOZOA_GENOME_REFERENCE/WG/bwt2/parasite_all"
parasiteFilesDir="${sampleAnalysisDir}06.PARASITE/" #directory where the files will we saved (sam for mapping and fastq for mapped samples)
noHostDir="${sampleAnalysisDir}02.HOST/" #directory where the host free samples are located
#		Input Files
noHostR1Fastq="${noHostDir}${sampleName}_noHost_R1.fastq" #R1 host free file
noHostR2Fastq="${noHostDir}${sampleName}_noHost_R2.fastq" #R2 host free file
#		Output Files: invertebrate
mappedSaminvertebrateFile="${parasiteFilesDir}${sampleName}_invertebrate_parasite_mapped.sam" #bowtie sam file with the reads that mapped against the invertebrate reference
bowtie2logFileinvertebrate="${parasiteFilesDir}${sampleName}_invertebrate_parasite_mapping.log" #log of the mapping against the invertebrate reference
parasiteMappedR1invertebrateFastq="${parasiteFilesDir}${sampleName}_invertebrate_parasite_R1.fastq" #file with the R1 reads which mapped against invertebrate reference
parasiteMappedR2invertebrateFastq="${parasiteFilesDir}${sampleName}_invertebrate_parasite_R2.fastq" #file with the R2 reads which mapped against the invertebrate reference
#					  protozoa
mappedSamprotozoaFile="${parasiteFilesDir}${sampleName}_protozoa_parasite_mapped.sam" #bowtie sam file with the reads that mapped against the protozoa reference
bowtie2logFileprotozoa="${parasiteFilesDir}${sampleName}_protozoa_parasite_mapping.log" #log of the mapping against the protozoa reference  
parasiteMappedR1protozoaFastq="${parasiteFilesDir}${sampleName}_protozoa_parasite_R1.fastq" #file with the R1 reads that mapped against the protozoa reference
parasiteMappedR2protozoaFastq="${parasiteFilesDir}${sampleName}_protozoa_parasite_R2.fastq" #file with the R2 reads that mapped against the protozoa reference


echo -e "$(date)" 
echo -e "*********** MAPPING PARASITE IN $sampleName ************"
#	CREATE DIRECTORY FOR THE SAMPLE IF NECESSARY
if [ ! -d ${parasiteFilesDir} ]
then
	mkdir -p $parasiteFilesDir
	echo -e "${parasiteFilesDir} created"
fi
################################################################################################	
#	BOWTIE2 MAPPING AGAINST invertebrate PARASITES	
echo -e "--------Bowtie2 is mapping against the invertebrate reference ....------"
echo -e "$(date)\t Start mapping ${sampleName} to invertebrate reference \n" > $bowtie2logFileinvertebrate
echo -e "The command is: ### bowtie2 -fr -x "$parasiteinvertebrateDB" -q -1 $noHostR1Fastq -2 $noHostR2Fastq -S $mappedSaminvertebrateFile ###\n" >> $bowtie2logFileinvertebrate 
bowtie2 -fr -x "$parasiteinvertebrateDB" -q -1 $noHostR1Fastq -2 $noHostR2Fastq -S $mappedSaminvertebrateFile 2>&1 | tee -a $bowtie2logFileinvertebrate
echo -e "$(date)\t Finished mapping ${sampleName} against invertebrate reference \n" >> $bowtie2logFileinvertebrate

#	SEPARATE AND EXTRACT R1 AND R2 READS MAPPED TO invertebrate 
echo -e "----------------- Filtering parasite reads that mapped to invertebrate ...---------------------"
echo -e "$(date)\t Start filtering ${sampleName} reads that mapped to invertebrate \n" >> $bowtie2logFileinvertebrate
echo -e "The command is: ###samtools view -F 0x40 $mappedSaminvertebrateFile | awk '{if($3 != '*') print '@' $1 '\\n' $10 '\\n' '+' '\\n' $11}' > $parasiteMappedR1invertebrateFastq" >> $bowtie2logFileinvertebrate
samtools view -F 0x40 $mappedSaminvertebrateFile | awk '{if($3 != "*") print "@" $1 "\n" $10 "\n" "+" $1 "\n" $11}' > $parasiteMappedR1invertebrateFastq
echo -e "The command is: ###samtools view -f 0x40 $mappedSaminvertebrateFile | awk '{if($3 != '*') print '@' $1 '\\n' $10 '\\n' '-' '\\n' $11}' > $parasiteMappedR2invertebrateFastq" >> $bowtie2logFileinvertebrate
samtools view -f 0x40 $mappedSaminvertebrateFile | awk '{if($3 != "*") print "@" $1 "\n" $10 "\n" "+" $1 "\n" $11}' > $parasiteMappedR2invertebrateFastq
#	samtools separates R1 (-F) or R2 (-f) reads using the mapped SAM file and awk filters those mapped (=!"*") in fastq format
echo -e "$(date)\t Finished filtering ${sampleName} reads that mapped to invertebrate \n" >> $bowtie2logFileinvertebrate

################################################################################################	
#	BOWTIE2 MAPPING AGAINST parasite protozoa	
echo -e "--------Bowtie2 is mapping against protozoa reference ....------"
echo -e "$(date)\t Start mapping ${sampleName} reads to protozoa reference \n" > $bowtie2logFileprotozoa
echo -e "The command is: ### bowtie2 -fr -x "$parasiteprotozoaDB" -q -1 $noHostR1Fastq -2 $noHostR2Fastq -S $mappedSamprotozoaFile ###\n" >> $bowtie2logFileprotozoa 
bowtie2 -fr -x "$parasiteprotozoaDB" -q -1 $noHostR1Fastq -2 $noHostR2Fastq -S $mappedSamprotozoaFile 2>&1 | tee -a $bowtie2logFileprotozoa
echo -e "$(date)\t Finished mapping ${sampleName} reads to protozoa reference \n" >> $bowtie2logFileprotozoa

#	SEPARATE AND EXTRACT R1 AND R2 READS MAPPED TO protozoa 
echo -e "----------------- Filtering parasite reads that mapped to protozoa reference ...---------------------"
echo -e "$(date)\t Start filtering ${sampleName} reads that mapped to protozoa \n" >> $bowtie2logFileprotozoa
echo -e "The command is: ###samtools view -F 0x40 $mappedSamprotozoaFile | awk '{if(\$3 != '*') print '@' \$1 '\\n' \$10 '\\n' '+' '\\n' \$11}' > $parasiteMappedR1protozoaFastq" >> $bowtie2logFileprotozoa
samtools view -F 0x40 $mappedSamprotozoaFile | awk '{if($3 != "*") print "@" $1 "\n" $10 "\n" "+" $1 "\n" $11}' > $parasiteMappedR1protozoaFastq
echo -e "The command is: ###samtools view -f 0x40 $mappedSamprotozoaFile | awk '{if(\$3 != '*') print '@' \$1 '\\n' \$10 '\\n' '+' '\\n' \$11}' > $parasiteMappedR2protozoaFastq" >> $bowtie2logFileprotozoa
samtools view -f 0x40 $mappedSamprotozoaFile | awk '{if($3 != "*") print "@" $1 "\n" $10 "\n" "+" $1 "\n" $11}' > $parasiteMappedR2protozoaFastq
#	samtools separates R1 (-F) or R2 (-f) reads using the mapped SAM file and awk filters those mapped (=!"*") in fastq format
echo -e "$(date)\t Finished filtering ${sampleName} reads that mapped to protozoa reference \n" >> $bowtie2logFileprotozoa


################################################################################################	
echo -e "$(date)" 
echo -e "*********** FINISHED MAPPING parasite IN $sampleName ************"
}

#module load samtools/samtools-1.2
map_parasite /processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/REFERENCES/PARASITE_GENOME_REFERENCE/ /processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/ANALYSIS/MuestraPrueba/
