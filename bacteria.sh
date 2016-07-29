#!/bin/bash
set -e

#   _                _            _       
#  | |__   __ _  ___| |_ ___ _ __(_) __ _ 
#  | '_ \ / _` |/ __| __/ _ \ '__| |/ _` |
#  | |_) | (_| | (__| ||  __/ |  | | (_| |
#  |_.__/ \__,_|\___|\__\___|_|  |_|\__,_|
# 

#	GLOBAL VARIABLES
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
bacDB="${workingDir}REFERENCES/BACTERIA_GENOME_REFERENCE/"

#	AWESOME SCRIPT
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
#["$1"="--"] && shift

function showHelp {
	echo -e 'Usage: bacteria -s <path_to_samples>'
	echo -e 'bacteria -h: show this help'
	exit 0
}

#	VARIABLES
sampleName=$(basename "${sampleDir}")
sampleAnalysisDir="${workingDir}ANALYSIS/${sampleName}"
bacteriaDir="${sampleAnalysisDir}/03.BACTERIA/"
sampleAnalysisLog="${sampleAnalysisDir}/${sampleName}_lablog.log"  

#	BACTERIA MAPPING
echo -e "$(date): ******** start mapping bacteria ***********" >> "${sampleAnalysisLog}"
echo -e "******************* Great! Let's map some bacteria ****************"
if [ ! -x ${workingDir}ANALYSIS/SRC/mapper_bac.sh ]
then
	chmod +x ${workingDir}ANALYSIS/SRC/mapper_bac.sh 
fi
#	execute bacteria mapping script
source ${workingDir}ANALYSIS/SRC/mapper_bac.sh
echo -e " Execute map_bacteria $bacDB $sampleAnalysisDir" >> "${sampleAnalysisLog}"
map_bacteria $bacDB $sampleAnalysisDir
echo -e "$(date): ******** Finished mapping bacteria **********" >> "${sampleAnalysisLog}"

#	ASSEMBLY FOR BACTERIA
echo -e "$(date): ******** start assemblying bacteria ***********" >> "${sampleAnalysisLog}"
echo -e "******************* wohooo! Bacteria assembly party! ****************"
if [ ! -x ${workingDir}ANALYSIS/SRC/assembly.sh ]
then
	chmod +x ${workingDir}ANALYSIS/SRC/assembly.sh 
fi
#	execute assembly script
source ${workingDir}ANALYSIS/SRC/assembly.sh
echo -e " Execute assemble $bacteriaDir" >> "${sampleAnalysisLog}"
assemble $bacteriaDir
echo -e "$(date): ******** Finished assemblying bacteria ***********" >> "${sampleAnalysisLog}"

#	BLAST 
echo -e "$(date): ******** Start running BLAST for bacteria ***********" >> "${sampleAnalysisLog}"
echo -e "******************* Drums, drums in the deep (of the sample, of course)... ****************"
if [ ! -x ${workingDir}ANALYSIS/SRC/blast.sh ]
then
	chmod +x ${workingDir}ANALYSIS/SRC/blast.sh 
fi
#	execute blast script
source ${workingDir}ANALYSIS/SRC/blast.sh 
echo -e " Execute blast $sampleAnalysisDir $bacDB" >> "${sampleAnalysisLog}"
blast $sampleAnalysisDir $bacDB
echo -e "$(date): ******** Finished bacteria blast ***********" >> "${sampleAnalysisLog}" 


#	COVERAGE 
echo -e "$(date): ******** Start calculating coverage for bacteria ***********" >> "${sampleAnalysisLog}"
echo -e "******************* Start calculating coverage for bacteria ****************"
if [ ! -x ${workingDir}ANALYSIS/SRC/coverage.sh ]
then
	chmod +x ${workingDir}ANALYSIS/SRC/coverage.sh 
fi
#	execute coverage script
echo -e " Execute coverage.sh $sampleAnalysisDir $bacDB" >> "${sampleAnalysisLog}"
coverage.sh $sampleAnalysisDir $bacDB
echo -e "$(date): ******** Finished bacteria coverage ***********" >> "${sampleAnalysisLog}" 






