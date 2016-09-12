#!/bin/bash
set -e

# Queremos ensamblar los contig que han blasteado conra la misma referencia para intentar sacar el genoma completo del bicho 
# 1. Se saca una lista de los organismos que matchean (uniq)
# 2. Se saca una lista de cada contig que ha matcheado con ese organismo
# 3. Se ensamblan los contig que matchean con el mismo organismo

#refDB=$1    
blastDir=$1 #workingDir/ANALYSIS/xx-organism/sampleName/blast/



workingDir="/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/"
sampleName=$(echo $blastDir | rev | cut -d'/' -f3 | rev) #gets the second to last column (sampleName)
organismDir=$(echo $blastDir | rev | cut -d'/' -f4 | rev) # gets the 3 to last column (xx-organism)
organism="${organismDir##*-}" # gets what is after the '-' and assumes is the organism
upperORG="$(echo $organism | tr '[:lower:]' '[:upper:]')"
sampleDir=$(echo $blastDir | rev | cut -d'/' -f3- | rev)
mauveDir="${sampleDir}/genomes/"
blastFile="${blastDir}*_filtered.blast"
dbFile="${workingDir}REFERENCES/*${upperORG}*/WG/*all.fna"

module load mauve-2.4_20150213

# CREATE DIRECTORY
if [ ! -d ${mauveDir} ]
then
	mkdir -p $mauveDir
	echo -e "${mauveDir} created"
fi

# FIND GENOMES
cat $blastFile | cut -f 1,3 | sort | uniq > "${mauveDir}/${sampleName}_organismList.txt"
cat "${mauveDir}/${sampleName}_organismList.txt"| while read in
do
	#sacamos el multifasta correspondiente a ese organismo
	genomeID=$(echo $in | rev | cut -d' ' -f 1 | rev)
	echo $genomeID
	genomeFile="${mauveDir}${genomeID}_contigs.fasta"
	cat $blastFile | awk -v id="$genomeID" -F $'\t' 'BEGIN {OFS = FS}{if($3 == id) print ">" $2 "\n" $14}' > $genomeFile
	# sacamos la referencia del multifasta
    cat $dbFile | awk -v id="$genomeID" 'BEGIN {RS=">"} $0 ~ id {print ">"$0}' > "${mauveDir}${genomeID}_genomeRef.fasta" 
    # lanzamos mauve
    java -Xmx500m -cp /opt/mauve-2.4_20150213/Mauve.jar org.gel.mauve.contigs.ContigOrderer -output $mauveDir -ref "${mauveDir}${genomeID}_genomeRef.fasta" -draft $genomeFile
    #por limpieza borramos el fasta con la referencia
    rm "${mauveDir}${genomeID}_genomeRef.fasta"
done


#java -Xmx500m -cp Mauve.jar org.gel.mauve.contigs.ContigOrderer -output results_dir -ref reference.gbk -draft draft.fasta
