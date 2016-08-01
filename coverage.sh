 set -e
#########################################################
#		  SCRIPT TO EVALUATE COVERAGE				 	#
#########################################################
# Arguments:
# $1 = (sampleAnalysisDir) Directory where the analysis is. 
# $2 = (refDB) Directory with the references.
# 1. Creates necessary directories. 
# 2. Calculates coverage.
# 
# Output files: (In ANALYSIS/sampleName/09.COVERAGE)
# sampleName_genome_coverage.txt: Coverage file from the BAM file.
# sampleName_coverage_log.log: Log file.


#	GET ARGUMENTS
sampleAnalysisDir=$1
refDB=$2
#	INITIALIZE VARIABLES
sampleName=$(basename $sampleAnalysisDir) # gets the sample name
organism=$(basename $refDB | cut -d'_' -f1) #gets the organism
genomeLength="${refDB}/WG/genome_length.txt"
genomeCov="${sampleAnalysisDir}/09.COVERAGE/${organism}/${sampleName}_genome_coverage.txt"
sampleBam="${sampleAnalysisDir}/*${organism}/*sorted.bam"
lablog="${sampleAnalysisDir}/09.COVERAGE/${organism}/${sampleName}_coverage_log.log"

module load bedtools2/bedtools2-2.25.0

echo -e "$(date)" 
echo -e "*********** CALCULATING COVERAGE OF $organism FOR $sampleName ************"

#	CREATE DIRECTORY FOR THE SAMPLE IF NECESSARY
if [ ! -d "${sampleAnalysisDir}/09.COVERAGE/${organism}/" ]
then
	mkdir -p "${sampleAnalysisDir}/09.COVERAGE/${organism}/"
	echo -e "${sampleAnalysisDir}/09.COVERAGE/${organism}/ created"
fi

################################################################################################	

echo -e "$(date)\t start running genomecov for ${sampleName}\n" > $lablog
echo -e "The command is: ### bedtools genomecov -ibam $sampleBam -g $genomeLength > $genomeCov ###" >> $lablog
bedtools genomecov -ibam $sampleBam -g $genomeLength > $genomeCov
echo -e "$(date)\t finished running genomecov for ${sampleName}\n" > $lablog






