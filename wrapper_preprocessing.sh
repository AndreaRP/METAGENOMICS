#!/bin/bash
set -e
cat /processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/ANALYSIS/samples_id.txt | while read in
do 
	#echo $in
	#mkdir $in
	bash /processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/ANALYSIS/SRC/preprocessing.sh -s $in
done

