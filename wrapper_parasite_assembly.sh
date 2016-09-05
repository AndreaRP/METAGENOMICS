
#!/bin/bash
set -e
#       execute bacteria mapping script
workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
source ${workingDir}ANALYSIS/SRC/assembly.sh
cat /processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/ANALYSIS/samples_id.txt | while read in
do
	mappedProtozoaDir="${workingDir}ANALYSIS/08-protozoa/${in}/reads/"
	mappedInvertebrateDir="${workingDir}ANALYSIS/09-invertebrate/${in}/reads/"
	assemble $mappedProtozoaDir
	assemble $mappedInvertebrateDir
done
