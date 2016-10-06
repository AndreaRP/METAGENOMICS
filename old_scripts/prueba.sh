set -e
#     
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
cat /processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/ANALYSIS/samples_id.txt | while read sampleName
do
	samplePreProQCDir="${workingDir}ANALYSIS/01-fastqc/${sampleName}"
	samplePostProQCDir="${workingDir}ANALYSIS/03-preproQC/${sampleName}"
	sampleStatsDir="${workingDir}ANALYSIS/99-stats/${sampleName}/"
	# copy fastqc files to 99-stats (y le cambio el nombre)
	find $samplePreProQCDir -name "*.zip" -exec unzip {} -d ${sampleStatsDir} \; 
	# change name of folder
	mv ${sampleStatsDir}*R1*/ "${sampleStatsDir}${sampleName}_prePro_R1_fastqc/"
	mv ${sampleStatsDir}*R2*/ "${sampleStatsDir}${sampleName}_prePro_R2_fastqc/"
	
	# copy fastqc files to 99-stats (y le cambio el nombre)
	find $samplePostProQCDir -name "*_paired_fastqc.zip" -exec unzip {} -d ${sampleStatsDir} \; 
	# change name of folder
	mv ${sampleStatsDir}${sampleName}*R1_paired*/ "${sampleStatsDir}${sampleName}_trimmed_R1_fastqc/"
	mv ${sampleStatsDir}${sampleName}*R2_paired*/ "${sampleStatsDir}${sampleName}_trimmed_R2_fastqc/"
done


