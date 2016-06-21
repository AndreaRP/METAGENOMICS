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
# sampleName_Virus_forward.fastq: .fastq file with forward reads that mapped the virus DB.
# sampleName_Virus_reverse.fastq: .fastq file with reverse reads that mapped the virus DB.
# sampleName_lablog.log: .log file with a log of the mapping.

function map_bacteria {
#	GET ARGUMENTS
virDB=$1  
sampleAnalysisDir=$2
#	INITIALIZE VARIABLES
#		Directories
sampleName=$(basename "${sampleAnalysisDir}")
virFilesDir="${sampleAnalysisDir}/04.VIRUS/" #directory where the host filtering files will we saved (sam for mapping and fastq for host free samples)
noHostDir="${sampleAnalysisDir}/02.HOST/"
#		Input Files
noHostForwardFastq="${noHostDir}${sampleName}_noHost_forward.fastq"
noHostReverseFastq="${noHostDir}${sampleName}_noHost_reverse.fastq"
#		OutputFiles
bowtie2logFile="${virFilesDir}${sampleName}_lablog.log"
VirMappedForwardFastq="${virFilesDir}${sampleName}_Virus_forward.fastq"
VirMappedReverseFastq="${virFilesDir}${sampleName}_Virus_reverse.fastq"
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
echo -e "The command is: ### bowtie2 -fr -x "$virDB" -q -1 $noHostForwardFastq -2 $noHostReverseFastq -S $mappedSamFile ###\n" >> $bowtie2logFile 
bowtie2 -fr -x "$virDB" -q -1 $noHostForwardFastq -2 $noHostReverseFastq -S $mappedSamFile 2>&1 | tee -a $bowtie2logFile
echo -e "$(date)\t Finished mapping ${sampleName}\n" >> $bowtie2logFile

#	SEPARATE FORWARD AND REVERSE MAPPED READS AND FILTER HOST
echo -e "----------------- Filtering bacteria reads ...---------------------"
echo -e "$(date)\t Start filtering ${sampleName}\n" > $bowtie2logFile
echo -e "The command is: ###samtools view -F 0x40 $mappedSamFile | awk '{if($3 =! "*") print "@"$1"\n"$10"\n""+"$1"\n"$11}' > $VirMappedForwardFastq"
samtools view -F 0x40 $mappedSamFile | awk '{if($3 =! "*") print "@"$1"\n"$10"\n""+"$1"\n"$11}' > $VirMappedForwardFastq
samtools view -f 0x40 $mappedSamFile | awk '{if($3 =! "*") print "@"$1"\n"$10"\n""+"$1"\n"$11}' > $VirMappedReverseFastq
#	samtools separates forward (-F) or reverse (-f) reads using the mapped SAM file and awk filters those mapped (=!"*") in fastq format
echo -e "$(date)\t Finished filtering ${sampleName}\n" > $bowtie2logFile

echo -e "$(date)" 
echo -e "*********** FINISHED MAPPING VIRUS IN $sampleName ************"
}
