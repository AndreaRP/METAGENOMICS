#!/bin/bash
set -e

#    __                   _ 
#   / _|_   _ _ __   __ _(_)
#  | |_| | | | '_ \ / _` | |
#  |  _| |_| | | | | (_| | |
#  |_|  \__,_|_| |_|\__, |_|
#  

#	GLOBAL VARIABLES
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
fungiDB="${workingDir}REFERENCES/FUNGI_GENOME_REFERENCE/"

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
	echo -e 'Usage: fungi -s <path_to_samples>'
	echo -e 'fungi -h: show this help'
	exit 0
}

#	VARIABLES
sampleName=$(basename "${sampleDir}")
sampleAnalysisDir="${workingDir}ANALYSIS/${sampleName}"
fungiDir="${sampleAnalysisDir}/05.FUNGI/"
sampleAnalysisLog="${sampleAnalysisDir}/${sampleName}_lablog.log"


#	FUNGI MAPPING
echo -e "$(date): ******** start mapping fungi ***********" >> "${sampleAnalysisLog}"
echo -e "******************* Mushroom hunting, yay! ****************"
if [ ! -x ${workingDir}ANALYSIS/SRC/mapper_fungi.sh ]
then
	chmod +x ${workingDir}ANALYSIS/SRC/mapper_fungi.sh 
fi
#	execute fungi mapping script
source ${workingDir}ANALYSIS/SRC/mapper_fungi.sh
echo -e " Execute map_fungi $fungiDB $sampleAnalysisDir" >> "${sampleAnalysisLog}"
map_fungi $fungiDB $sampleAnalysisDir
echo -e "$(date): ******** Finished mapping fungi **********" >> "${sampleAnalysisLog}"

#	ASSEMBLY FOR FUNGI
echo -e "$(date): ******** Start assemblying fungi ***********" >> "${sampleAnalysisLog}"
echo -e "******************* Assemblying is fun(gi)!! ****************"
if [ ! -x ${workingDir}ANALYSIS/SRC/assembly.sh ]
then
	chmod +x ${workingDir}ANALYSIS/SRC/assembly.sh 
fi
#	execute assembly script
source ${workingDir}ANALYSIS/SRC/assembly.sh
echo -e " Execute assemble $fungiDir" >> "${sampleAnalysisLog}"
assemble $fungiDir
echo -e "$(date): ******** Finished assemblying fungi ***********" >> "${sampleAnalysisLog}"

#	BLAST 
echo -e "$(date): ******** Start running BLAST for fungi ***********" >> "${sampleAnalysisLog}"
echo -e "******************* Can we eat the fungi we found? BLAST will say ****************"
if [ ! -x ${workingDir}ANALYSIS/SRC/blast.sh ]
then
	chmod +x ${workingDir}ANALYSIS/SRC/blast.sh 
fi
#	execute blast script
source ${workingDir}ANALYSIS/SRC/blast.sh 
echo -e " Execute blast $sampleAnalysisDir $fungiDB" >> "${sampleAnalysisLog}"
blast $sampleAnalysisDir $fungiDB
echo -e "$(date): ******** Finished fungi blast ***********" >> "${sampleAnalysisLog}"


#	COVERAGE 
echo -e "$(date): ******** Start calculating coverage for fungi ***********" >> "${sampleAnalysisLog}"
echo -e "******************* Start calculating coverage for fungi ****************"
if [ ! -x ${workingDir}ANALYSIS/SRC/coverage.sh ]
then
	chmod +x ${workingDir}ANALYSIS/SRC/coverage.sh 
fi
#	execute coverage script
echo -e " Execute coverage.sh $sampleAnalysisDir $fungiDB" >> "${sampleAnalysisLog}"
coverage.sh $sampleAnalysisDir $fungiDB
echo -e "$(date): ******** Finished fungi coverage ***********" >> "${sampleAnalysisLog}" 
