#!/bin/bash
set -e

#########################################################
#		  		BACTERIA COVERAGE WRAPPER				 	#
#########################################################

# 1. Runs coverage.sh* with every sample included in samples_id.txt**
# 2. Runs graphs_coverage.R for every sample in samples_id.txt**
# * Note: This script must only be used after running wrapper_virus_mapper.sh
#       execute bacteria coverage script


workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
bacDB="${workingDir}REFERENCES/BACTERIA_GENOME_REFERENCE/"

# Calculates coverage for each sample
cat ${workingDir}ANALYSIS/samples_id.txt | while read in
do
	sampleDir="${workingDir}ANALYSIS/05-bacteria/${in}/"
	${workingDir}ANALYSIS/SRC/coverage.sh $sampleDir $bacDB
done

# generates coverage data for each sample
cat ${workingDir}ANALYSIS/samples_id.txt | while read in
do
	Rscript ${workingDir}ANALYSIS/SRC/graphs_coverage.R "${workingDir}ANALYSIS/05-bacteria/${in}/coverage/" ${in}
done

