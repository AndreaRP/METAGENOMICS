set -e
#########################################################
#  SCRIPT TO RUN BLAST LOCALLY AGAINST NCBI VIRUS SEQ.	#
#########################################################
# Arguments:
# $1 = Directory with the sample analysis.
# $2 = Directory where the blast db is located
# 1. Creates necessary directories. 
# 2. Runs BLASTn against the reference.
# 3. Runs BLASTx against the reference.
# Output files: (In ANALYSIS/sampleName/06.BLAST)

function blast {
#	GET ARGUMENTS
sampleAnalysisDir=$1
virDB=$2
#	INITIALIZE VARIABLES
sampleName=$(basename $sampleAnalysisDir) # gets the sample name
vir_BLASTn_DB="${virDB}blastn/viral_blastn"
vir_BLASTx_DB="${virDB}blastx/viral_blastx"
#		Directories
outputDir="${sampleAnalysisDir}06.BLAST/VIRUS/"
#		Input Files
sampleContig="${sampleAnalysisDir}05.ASSEMBLY/VIRUS/spades/contigs.fasta"
#		Output Files
blastnResult="${outputDir}${sampleName}_BLASTn.blast"
blastxResult="${outputDir}${sampleName}_BLASTx.blast"
lablog="${outputDir}${sampleName}_blast_log.log"
contigFaa="${outputDir}${sampleName}_contig_aa.faa"
blastnHits="${outputDir}blastn_Hits.txt"

echo -e "$(date)" 
echo -e "*********** BLAST $sampleName ************"

#	CREATE DIRECTORY FOR THE SAMPLE IF NECESSARY
if [ ! -d ${outputDir} ]
then
	mkdir -p $outputDir
	echo -e "${outputDir} created"
fi
	
#	RUN BLASTn	
echo -e "$(date)\t start running BLASTn for ${sampleName}\n" > $lablog
echo -e "$(date)\t start running BLASTn for ${sampleName}"
echo -e "The command is: ### blastn -db $vir_BLASTn_DB -query $sampleContig -html > $blastResult ###" >> $lablog
blastn -db $vir_BLASTn_DB -query $sampleContig -outfmt 7 > $blastnResult 
echo -e "$(date)\t finished running BLASTn for ${sampleName}\n" >> $lablog
#	RUN BLASTx and RAPSearch2
echo -e "$(date)\t start running BLASTx for ${sampleName}\n" >> $lablog
echo -e "$(date)\t start running BLASTx for ${sampleName}" 
echo -e "The command is: ### blastx -db $vir_BLASTx_DB -query $sampleContig -html > $blastResult ###" >> $lablog
blastx -db $vir_BLASTx_DB -query $sampleContig -html > $blastxResult 
echo -e "$(date)\t finished running BLASTx for ${sampleName}\n" >> $lablog

#grep -A 5 -B 3 ">" $blastnResult > $blastnHits

}

blast /processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/ANALYSIS/MuestraPrueba/ /processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/REFERENCES/VIRUS_GENOME_REFERENCE/
