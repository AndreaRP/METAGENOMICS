#!/bin/bash
set -e
#       execute bacteria mapping script
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
protozoaDB="${workingDir}REFERENCES/PROTOZOA_GENOME_REFERENCE/"
invertebrateDB="${workingDir}REFERENCES/INVERTEBRATE_GENOME_REFERENCE/"
cat ${workingDir}ANALYSIS/samples_id.txt | while read in
do
	sampleProtozoaDir="${workingDir}ANALYSIS/08-protozoa/${in}/"
	sampleInvertebrateDir="${workingDir}ANALYSIS/09-invertebrate/${in}/"
	${workingDir}ANALYSIS/SRC/coverage.sh $sampleProtozoaDir $protozoaDB
	${workingDir}ANALYSIS/SRC/coverage.sh $sampleInvertebrateDir $invertebrateDB
done

