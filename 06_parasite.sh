#!/bin/bash
set -e
#                             _ _       
#   _ __   __ _ _ __ __ _ ___(_) |_ ___ 
#  | '_ \ / _` | '__/ _` / __| | __/ _ \
#  | |_) | (_| | | | (_| \__ \ | ||  __/
#  | .__/ \__,_|_|  \__,_|___/_|\__\___|
#  |_| 


#	GLOBAL VARIABLES
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
parasiteDB="${workingDir}REFERENCES/"

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
	echo -e 'Usage: vagancia -s <path_to_samples>'
	echo -e 'vagancia -h: show this help'
	exit 0
}

#	VARIABLES
sampleName=$(basename "${sampleDir}")
sampleAnalysisDir="${workingDir}ANALYSIS/${sampleName}"
parasiteDir="${sampleAnalysisDir}/06.PARASITE/"
sampleAnalysisLog="${sampleAnalysisDir}/${sampleName}_lablog.log" 

#	PARASITE MAPPING
echo -e "$(date): ******** start mapping parasite ***********" >> "${sampleAnalysisLog}"
echo -e "******************* parasites.... are you there? ****************"
if [ ! -x ${workingDir}ANALYSIS/SRC/mapper_parasite.sh ]
then
	chmod +x ${workingDir}ANALYSIS/SRC/mapper_parasite.sh 
fi
#	execute parasite mapping script
source ${workingDir}ANALYSIS/SRC/mapper_parasite.sh
echo -e " Execute map_parasite $parasiteDB $sampleAnalysisDir" >> "${sampleAnalysisLog}"
map_parasite $parasiteDB $sampleAnalysisDir
echo -e "$(date): ******** Finished mapping parasite **********" >> "${sampleAnalysisLog}"

#	ASSEMBLY FOR PARASITES	
echo -e "$(date): ******** Start assemblying parasites ***********" >> "${sampleAnalysisLog}"
echo -e "******************* If we assemble paras... do we get parasite? ****************"
if [ ! -x ${workingDir}ANALYSIS/SRC/assembly.sh ]
then
	chmod +x ${workingDir}ANALYSIS/SRC/assembly.sh 
fi
#	execute assembly script
source ${workingDir}ANALYSIS/SRC/assembly.sh
echo -e " Execute assemble $parasiteDir" >> "${sampleAnalysisLog}"
assemble $parasiteDir
echo -e "$(date): ******** Finished assemblying parasites ***********" >> "${sampleAnalysisLog}"

#	BLAST 
echo -e "$(date): ******** Start running BLAST for parasites ***********" >> "${sampleAnalysisLog}"
echo -e "******************* BLASTed parasites! ****************"
if [ ! -x ${workingDir}ANALYSIS/SRC/blast.sh ]
then
	chmod +x ${workingDir}ANALYSIS/SRC/blast.sh 
fi
#	execute blast script
source ${workingDir}ANALYSIS/SRC/blast.sh 
echo -e " Execute blast $sampleAnalysisDir $parasiteDB" >> "${sampleAnalysisLog}"
blast $sampleAnalysisDir $parasiteDB
echo -e "$(date): ******** Finished parasite blast ***********" >> "${sampleAnalysisLog}"
