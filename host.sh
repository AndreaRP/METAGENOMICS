#!/bin/bash
set -e

#   _               _                                        _ 
#  | |__   ___  ___| |_   _ __ ___ _ __ ___   _____   ____ _| |
#  | '_ \ / _ \/ __| __| | '__/ _ \ '_ ` _ \ / _ \ \ / / _` | |
#  | | | | (_) \__ \ |_  | | |  __/ | | | | | (_) \ V / (_| | |
#  |_| |_|\___/|___/\__| |_|  \___|_| |_| |_|\___/ \_/ \__,_|_|
# 




echo -e "PIPELINE START: $(date)"
#	Get parameters:
sampleDir=''
while getopts "hs:" opt
do
	case "$opt" in
	h)	showHelp
		;;
	s)	sampleDir=$OPTARG
		;;
	esac
done
shift $((OPTIND-1))

function showHelp {
	echo -e 'Usage: host -s <path_to_samples>'
	echo -e 'host -h: show this help'
	exit 0
}

#	CONSTANTS
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
hostDB="${workingDir}REFERENCES/HUMAN_GENOME_REFERENCE/"

#	VARIABLES
sampleName=$(basename "${sampleDir}")
sampleAnalysisDir="${workingDir}ANALYSIS/02-preprocessing/${sampleName}/"
sampleAnalysisLog="${sampleAnalysisDir}/${sampleName}_lablog.log"


#	HOST REMOVAL
echo -e "$(date): ************* Start host removal ***************" >> "${sampleAnalysisLog}"
echo -e "************** Now, we need to remove the host genome *************" 
if [ ! -x ${workingDir}ANALYSIS/SRC/host_removal.sh ]
then
	chmod +x ${workingDir}ANALYSIS/SRC/host_removal.sh   
fi
#	execute host removal script
source ${workingDir}ANALYSIS/SRC/host_removal.sh
echo -e " Execute removeHost $hostDB $sampleAnalysisDir" >> "${sampleAnalysisLog}"
removeHost $hostDB $sampleAnalysisDir 
echo -e "$(date): ************ Finished host removal ************" >> "${sampleAnalysisLog}"
