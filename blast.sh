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
sampleDir=$1  #workingDir/ANALYSIS/xx-organism/sampleName/
refDB=$2
#	INITIALIZE VARIABLES
sampleName=$(basename $sampleDir) # gets the sample name
organismDir=$(echo $sampleDir | rev | cut -d'/' -f3 | rev) # gets the 3 to last column (xx-organism)
organism="${organismDir##*-}" # gets what is after the '-' and assumes is the organism
blastDB="${refDB}BLAST/"
upOrganism=$(echo $organism | tr '[:lower:]' '[:upper:]')
BLASTn_DB="${blastDB}blastn/${upOrganism}_blastn"
BLASTx_DB="${blastDB}blastx/${upOrganism}_blastx"
#		Directories
outputDir="${sampleDir}/blast/"
#		Input Files
sampleContig="${sampleDir}/contigs/contigs.fasta"
#		Output Files
blastnResult="${outputDir}${sampleName}_BLASTn.blast"
blastnResultFiltered="${outputDir}${sampleName}_BLASTn_filtered.blast"
blastxResult="${outputDir}${sampleName}_BLASTx.blast"
lablog="${outputDir}${sampleName}_blast_log.log"
contigFaa="${outputDir}${sampleName}_contig_aa.faa"
blastnHits="${outputDir}blastn_Hits.txt"

module load ncbi_blast-2.2.30+

echo -e "$(date)" 
echo -e "*********** BLAST $sampleName ************"

#	CREATE DIRECTORY FOR THE SAMPLE IF NECESSARY
if [ ! -d ${outputDir} ]
then
	mkdir -p $outputDir
	echo -e "${outputDir} created"
fi
	
#	RUN BLASTn	
if [ ! -f $sampleContig ]; then
	echo "$sampleContig file not found!" > $lablog
else
	echo -e "$(date)\t start running BLASTn for ${sampleName}\n" > $lablog
	echo -e "$(date)\t start running BLASTn for ${sampleName}"
	echo -e "The command is: ### blastn -db $BLASTn_DB -query $sampleContig -outfmt '6 stitle staxids std qseq' > $blastResult ###" >> $lablog
	blastn -db $BLASTn_DB -query $sampleContig -outfmt '6 stitle std qseq' > $blastnResult 
	echo -e "$(date)\t finished running BLASTn for ${sampleName}\n" >> $lablog
	#	Filter blast results that pass min 100 length (col. 5) and 90% alignment (col. 4).
	awk -F "\t" '{if($4 >= 90 && $5>= 100) print $0}' $blastnResult > $blastnResultFiltered
	
	#	CREATE FASTA WITH SEQUENCES THAT ALIGN 
	
	
	#	RUN BLASTx and RAPSearch2
	#echo -e "$(date)\t start running BLASTx for ${sampleName}\n" >> $lablog
	#echo -e "$(date)\t start running BLASTx for ${sampleName}" 
	#echo -e "The command is: ### blastx -db $BLASTx_DB -query $sampleContig -html > $blastResult ###" >> $lablog
	#blastx -db $BLASTx_DB -query $sampleContig -outfmt '6 stitle std' > $blastxResult 
	#echo -e "$(date)\t finished running BLASTx for ${sampleName}\n" >> $lablog
	
	#grep -A 5 -B 3 ">" $blastnResult > $blastnHits

fi
}

#blast /processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/ANALYSIS/Unai16/ /processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/REFERENCES/BACTERIA_GENOME_REFERENCE/
