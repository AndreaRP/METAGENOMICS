#!/bin/bash
set -e

#                     _ _ _                           _             _ 
#    __ _ _   _  __ _| (_) |_ _   _    ___ ___  _ __ | |_ _ __ ___ | |
#   / _` | | | |/ _` | | | __| | | |  / __/ _ \| '_ \| __| '__/ _ \| |
#  | (_| | |_| | (_| | | | |_| |_| | | (_| (_) | | | | |_| | | (_) | |
#   \__, |\__,_|\__,_|_|_|\__|\__, |  \___\___/|_| |_|\__|_|  \___/|_|
#      |_|                    |___/                                   


#	GLOBAL VARIABLES
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/' 

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
	echo -e 'Usage: preprocessing -s <path_to_samples>'
	echo -e 'the path to samples must contain the fastq sequences. Tha file name must contain R1 or R2.'
	echo -e 'preprocessing -h: show this help'	
	exit 0
}

#	VARIABLES
sampleName=$(basename "${sampleDir}")
sampleAnalysisDir="${workingDir}ANALYSIS/${sampleName}"
rawDir="${workingDir}RAW/${sampleName}"
sampleAnalysisLog="${sampleAnalysisDir}/${sampleName}_lablog.log"

if [ ! -d "${sampleAnalysisDir}" ]
then
	mkdir -p "$sampleAnalysisDir"
fi

#	TRIMMOMMATIC QUALITY CONTROL
#	Create sh file
echo -e "$(date): ********* Start quaility control **********" > "${sampleAnalysisLog}"
echo -e "************** First, let's do a bit of quality control *************"  
if [ ! -d "${sampleAnalysisDir}/01.PREPROCESSING/TRIMMOMATIC/" ]
then
	mkdir -p "$sampleAnalysisDir/01.PREPROCESSING/TRIMMOMATIC"
	echo -e "${sampleAnalysisDir}/01.PREPROCESSING/TRIMMOMATIC created"
fi
echo -e "Command: python ${workingDir}ANALYSIS/SRC/trimmomatic.py -i ${rawDir} -o ${sampleAnalysisDir}/01.PREPROCESSING/TRIMMOMATIC/ -n $sampleName" >> "${sampleAnalysisLog}"
python ${workingDir}ANALYSIS/SRC/trimmomatic.py -i ${rawDir} -o ${sampleAnalysisDir}/01.PREPROCESSING/TRIMMOMATIC/ -n $sampleName
#	Execute sh file
if [ ! -x "${sampleAnalysisDir}/01.PREPROCESSING/TRIMMOMATIC/trimmomatic.sh" ]
then
	chmod +x "${sampleAnalysisDir}/01.PREPROCESSING/TRIMMOMATIC/trimmomatic.sh"
fi
echo -e "$(date): Execute ${sampleAnalysisDir}/01.PREPROCESSING/TRIMMOMATIC/trimmomatic.sh" >> "${sampleAnalysisLog}"
$(${sampleAnalysisDir}/01.PREPROCESSING/TRIMMOMATIC/trimmomatic.sh) 
echo -e "$(date): Finished executing trimmommatic" >> "${sampleAnalysisLog}"
#	Execute fastqc 
if [ ! -x ${workingDir}ANALYSIS/SRC/fastqc.sh ]
then
	chmod +x ${workingDir}ANALYSIS/SRC/fastqc.sh   
fi
echo -e "$(date): Execute fastqc.sh" >> "${sampleAnalysisLog}"
${workingDir}ANALYSIS/SRC/fastqc.sh $sampleAnalysisDir
echo -e "$(date): Finish fastqc.sh" >> "${sampleAnalysisLog}"
echo -e "$(date): ********* Finished quaility control **********" >> "${sampleAnalysisLog}"