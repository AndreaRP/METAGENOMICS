 set -e
#########################################################
#		  SCRIPT TO EVALUATE COVERAGE				 	#
#########################################################
# Arguments:
# $1 = (sampleDir) Directory where the analysis is. 
# $2 = (refDB) Directory with the references.
# 1. Creates necessary directories. 
# 2. Calculates coverage.
# 
# Output files: (In ANALYSIS/sampleName/09.COVERAGE)
# sampleName_genome_coverage.txt: Coverage file from the BAM file.
# sampleName_coverage_log.log: Log file.


#	GET ARGUMENTS
sampleDir=$1  #workingDir/ANALYSIS/xx-organism/sampleName/
refDB=$2
#	INITIALIZE VARIABLES
sampleName=$(basename $sampleDir) # gets the sample name
organismDir=$(echo $sampleDir | rev | cut -d'/' -f3 | rev) # gets the 3 to last column (xx-organism)
workingDir="$(echo $sampleDir | rev | cut -d'/' -f4- | rev)/SRC/" # gets up to the 3 to last column 
organism="${organismDir##*-}" # gets what is after the '-' and assumes is the organism
genomeLength="${refDB}/WG/genome_length.txt"
genomeCov="${sampleDir}/coverage/${sampleName}_genome_coverage.txt"
sampleBam="${sampleDir}/reads/*sorted.bam"
lablog="${sampleDir}/coverage/${sampleName}_coverage_log.log"

module load bedtools2/bedtools2-2.25.0
module load R/R-3.2.5

echo -e "$(date)" 
echo -e "*********** CALCULATING COVERAGE OF $organism IN SAMPLE $sampleName ************"

#	CREATE DIRECTORY FOR THE SAMPLE IF NECESSARY
if [ ! -d "${sampleDir}/coverage/" ]
then
	mkdir -p "${sampleDir}/coverage/"
	echo -e "${sampleDir}/coverage/ created"
fi

################################################################################################	

echo -e "$(date)\t start running genomecov for ${sampleName}\n" > $lablog
echo -e "The command is: ### bedtools genomecov -ibam $sampleBam -g $genomeLength > $genomeCov ###" >> $lablog
bedtools genomecov -ibam $sampleBam -g $genomeLength > $genomeCov
echo -e "$(date)\t finished running genomecov for ${sampleName}\n" >> $lablog


################################################################################################	
echo -e "$(date)\t start generating coverage graphs for ${sampleName}\n" >> $lablog
echo -e "The command is: ### Rscript --vanilla ${sampleDir}/coverage/ ${sampleName} ###" >> $lablog
Rscript --vanilla "${workingDir}/graphs_coverage.R" "${sampleDir}/coverage/" ${sampleName}
echo -e "$(date)\t finished coverage graphs for ${sampleName}\n" >> $lablog





