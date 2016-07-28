#!/bin/bash
set -e 

#         _                
#  __   _(_)_ __ _   _ ___ 
#  \ \ / / | '__| | | / __|
#   \ V /| | |  | |_| \__ \
#    \_/ |_|_|   \__,_|___/
#                          

#	GLOBAL VARIABLES
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
virDB="${workingDir}REFERENCES/VIRUS_GENOME_REFERENCE/"


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
	echo -e 'Usage: virus -s <path_to_samples>'
	echo -e 'virus -h: show this help'
	exit 0
}

#	VARIABLES
sampleName=$(basename "${sampleDir}")
sampleAnalysisDir="${workingDir}ANALYSIS/${sampleName}"
virusDir="${sampleAnalysisDir}/04.VIRUS/"
sampleAnalysisLog="${sampleAnalysisDir}/${sampleName}_lablog.log"

#	VIRUS MAPPING
echo -e "$(date): ******** start mapping virus ***********" >> "${sampleAnalysisLog}"
echo -e "******************* Great! Let's map some virus ****************"
if [ ! -x ${workingDir}ANALYSIS/SRC/mapper_virus.sh ]
then
	chmod +x ${workingDir}ANALYSIS/SRC/mapper_virus.sh 
fi
#	execute virus mapping script
source ${workingDir}ANALYSIS/SRC/mapper_virus.sh
echo -e " Execute map_virus $virDB $sampleAnalysisDir" >> "${sampleAnalysisLog}"
map_virus $virDB $sampleAnalysisDir
echo -e "$(date): ******** Finished mapping virus **********" >> "${sampleAnalysisLog}"

#	ASSEMBLY FOR VIRUS
echo -e "$(date): ******** Start assemblying virus ***********" >> "${sampleAnalysisLog}"
echo -e "******************* weeeeeeee! Virus assembly party! ****************"
if [ ! -x ${workingDir}ANALYSIS/SRC/assembly.sh ]
then
	chmod +x ${workingDir}ANALYSIS/SRC/assembly.sh 
fi
#	execute assembly script
source ${workingDir}ANALYSIS/SRC/assembly.sh
echo -e " Execute assemble $virusDir" >> "${sampleAnalysisLog}"
assemble $virusDir
echo -e "$(date): ******** Finished assemblying virus ***********" >> "${sampleAnalysisLog}"

#	BLAST 
echo -e "$(date): ******** Start running BLAST for virus ***********" >> "${sampleAnalysisLog}"
echo -e "******************* This is it! Let's see what hides in the deepness of the sample ****************"
if [ ! -x ${workingDir}ANALYSIS/SRC/blast.sh ]
then
	chmod +x ${workingDir}ANALYSIS/SRC/blast.sh 
fi
#	execute blast script
source ${workingDir}ANALYSIS/SRC/blast.sh 
echo -e " Execute blast $sampleAnalysisDir $virDB" >> "${sampleAnalysisLog}"
blast $sampleAnalysisDir $virDB
echo -e "$(date): ******** Finished virus blast ***********" >> "${sampleAnalysisLog}"
