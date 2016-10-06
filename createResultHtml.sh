#!/bin/bash
set -e

#########################################################
#	SCRIPT TO CREATE HTML REPORT OF THE BLAST RESULTS	#
#########################################################
# 1. Creates necessary directories. 
# 2. Generates html with the BLASTn and BLASTx files.
# Note: This script should only be run after running blast.sh. The script createIndex.sh should be run
# before this report can be viewed correctly. 

# Arguments:
# $1 (sampleDir) = Directory of the organism analysis of the sample. (ANALYSIS/xx-organism/sampleName/)

# Input Files: (In ANALYSIS/xx-organism/sampleName/blast/)
# sampleName_BLASTn_filtered.blast: Filtered blast file (containing only hits >100bp and >90% identity)

# Output files: (In RESULTS/xx-organism/sampleName/blast/)
# blastn.html: html file 
# blastx.html

workingDir='/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/'
sampleName="C1" # (sampleName)
organism="bacteria"
sampleResult="${workingDir}RESULTS/data/C1_bacteria_results.txt"
result_page="${workingDir}RESULTS/C1_bacteria_results.html"
#	GET PARAMETERS
#sampleDir=$1  #/workingDir/ANALYSIS/xx-organism/sampleName/

#	INITIALIZE VARIABLES
genomeId=""
coverageFile=""
#		CONSTANTS
#sampleName=$(basename $sampleDir) # (sampleName)

#workingDir="$(echo $sampleDir | rev | cut -d'/' -f5- | rev)/" # (workingDir) 
#organismDir=$(echo $sampleDir | rev | cut -d'/' -f3 | rev) # (xx-organism)
#organism="${organismDir##*-}" # (organism)
#		INPUT FILES
#sampleResult="${workingDir}RESULTS/data/${sampleName}_${organism}_results.txt"
#		OUTPUT FILES
#result_page="${workingDir}/RESULTS/${sampleName}_${organism}_results.html"


echo "
<html>
	<head>
   		<title>" > $result_page
   		 echo "$sampleName ${organism} results" >> $result_page
   		 echo "
   		</title>
   		<link rel='stylesheet' type='text/css' href='css/table.css'>
   		<link rel='stylesheet' type='text/css' href='css/deco.css' />
   	 	<meta content=''>
	</head>
	<body>
		<table>
			<thead>
		   		<tr>
		   		    <th>" >> $result_page
				    echo "${sampleName} ${organism} result" >> $result_page
				    echo "</th>
				    <!--<th>Subject Title</th>-->
					<th>Reference Id</th>
					<th>Reference name</th>
					<th>% of identical matches</th>
					<th>Alignment length</th>
					<th>Number of mismatches</th>
					<th>Number of gap openings</th>
					<th>Start of alignment in query</th>
					<th>End of alignment in query</th>
					<th>Start of alignment in subject</th>
					<th>End of alignment in subject</th>
					<th>Expect value</th>
					<th>Bit score</th>
					<th>Coverage mean</th>
					<th>Minimum coverage</th>
					<th>Maximum coverage</th>
					<th>Coverage SD</th>
					<th>x1-x4 depth</th>
					<th>x5-x9 depth</th>
					<th>x10-x9 depth</th>
					<th> >20 depth</th>
					<th>Coverage graph</th>
				</tr>
			</thead>
			<tbody>" >> $result_page
				#	Start formatting data 
				while IFS='' read -r line || [[ -n $line ]]
				do
					echo "
				<tr>" >> $result_page
					IFS='	' read -r -a array <<< "$line"
					#organism="${organismDir##*-}" # (organism)
					echo "<th>"$(echo ${array[1]//\"/} | cut -f1 -d',')"</th>">> $result_page
					#for value in "${array[@]:1:12}"
					for (( i = 0; i < ${#array[@]}; i++))
					do
						echo "<td>${array[$i]//\"/}</td>" >> $result_page
					done
					# conseguir el genome id
					genomeId=${array[0]//\"/}
					coverageFile="${sampleDir}coverage/${genomeId}_coverage_graph.pdf"
					echo "<td><a target='_blank' href='$coverageFile'>${genomeId}</a></td>" >> $result_page
					echo "</tr>" >> $result_page
			done < ${sampleResult}
		echo "</tbody>
		</table>
		<script src='http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js'></script>
		<script src='http://cdnjs.cloudflare.com/ajax/libs/jquery-throttle-debounce/1.1/jquery.ba-throttle-debounce.min.js'></script>
		<script src='js/jquery.stickyheader.js'></script>
	</body>
</html>" >> $result_page
