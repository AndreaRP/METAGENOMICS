#!/bin/bash
#set -e
#       execute bacteria mapping script
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
protozoaDB="${workingDir}REFERENCES/PROTOZOA_GENOME_REFERENCE/"
invertebrateDB="${workingDir}REFERENCES/INVERTEBRATE_GENOME_REFERENCE/"
source ${workingDir}ANALYSIS/SRC/blast.sh
cat ${workingDir}ANALYSIS/samples_id.txt | while read in
do
	sampleProtozoaDir="${workingDir}ANALYSIS/08-protozoa/${in}/"
	sampleInvertebrateDir="${workingDir}ANALYSIS/09-invertebrate/${in}/"
	blast $sampleProtozoaDir $protozoaDB
	blast $sampleInvertebrateDir $invertebrateDB
done
