
set -e
#########################################################
#  SCRIPT TO RUN FASTQC ON EACH FASTQ 					#
#########################################################
# Arguments:
# $1 = Directory with the sample analysis.
# 1. Creates necessary directories. 
# 2. Runs fastqc for each fastq file trimmed with trimmommatic.
# Output files: (In ANALYSIS/sampleName/01.PREPROCESSING/fastqc/)
# 	sample_output_R1_paired_fastqc.html
# 	sample_output_R2_paired_fastqc.html
# 	sample_output_R1_unpaired_fastqc.html
# 	sample_output_R2_unpaired_fastqc.html
# 	fastqc_lablog.log

#	Get parameters
analysisDir=$1

#	Directories and files
fastqcDir="${analysisDir}/01.PREPROCESSING/fastqc/"
trimmommaticDir="${analysisDir}/01.PREPROCESSING/TRIMMOMATIC/"
fastqcLablog="${fastqcDir}/fastqc_lablog.log"

#	create directory if it doesn't exist
if [ ! -d ${fastqcDir} ]
then
	mkdir -p $fastqcDir
	echo -e "${fastqcDir} created"
fi

#	execute fastqc for each fastq
echo -e "$(date)\t Start fastqc \n" > $fastqcLablog
find $trimmommaticDir -name "*.fastq" -exec fastqc {} --outdir $fastqcDir \; >> $fastqcLablog
echo -e "$(date)\t End fastqc \n" > $fastqcLablog

#for file in $( ls $trimmommaticDir )
#do
#	fastqc ${file} --outdir $fastqcDir
#done



