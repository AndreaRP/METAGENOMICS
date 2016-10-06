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

#	GET PARAMETERS
sampleDir=$1  #/workingDir/ANALYSIS/xx-organism/sampleName/

#	INITIALIZE VARIABLES
genomeId=""
coverageFile=""
#		CONSTANTS
sampleName=$(basename $sampleDir) # (sampleName)
workingDir="$(echo $sampleDir | rev | cut -d'/' -f5- | rev)/" # (workingDir) 
organismDir=$(echo $sampleDir | rev | cut -d'/' -f3 | rev) # (xx-organism)
organism="${organismDir##*-}" # (organism)
#		INPUT FILES
blastnResult="${sampleDir}blast/${sampleName}_BLASTn_filtered.blast"
#blastxResult="${sampleDir}blast/${sampleName}_BLASTx_filtered.blast"
#		OUTPUT FILES
result_blastn_page="${workingDir}/RESULTS/${organismDir}/${sampleName}/blast/blastn.html"
#result_blastx_page="${workingDir}/RESULTS/${organismDir}/${sampleName}/blast/blastx.html"

mkdir -p "${workingDir}/RESULTS/${organismDir}/${sampleName}/blast/"

echo "
<html>
	<head>
   		<title>" > $result_blastn_page
   		 echo "$sampleName blast" >> $result_blastn_page
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
		   			<th>" >> $result_blastn_page
					echo "${sampleName} blast result" >> $result_blastn_page
					echo "</th>
					<!--<th>Subject Title</th>-->
					<th>Query Seq-id</th>
					<th>Reference Id</th>
					<th>Percentage of identical matches</th>
					<th>Alignment length</th>
					<th>Number of mismatches</th>
					<th>Number of gap openings</th>
					<th>Start of alignment in query</th>
					<th>End of alignment in query</th>
					<th>Start of alignment in subject</th>
					<th>End of alignment in subject</th>
					<th>Expect value</th>
					<th>Bit score</th>
					<th>Genome coverage</th>
				</tr>
			</thead>
			<tbody>" >> $result_blastn_page
				#	Start formatting data from blast
				while IFS='' read -r line || [[ -n $line ]]
				do
					echo "
				<tr>" >> $result_blastn_page
					IFS='	' read -r -a array <<< "$line"
					echo "<th>${array[0]}</th>">> $result_blastn_page
					for value in "${array[@]:1:12}"
					do
						echo "<td>${value}</td>" >> $result_blastn_page
					done
					# conseguir el genome id
					genomeId="${array[2]}"
					coverageFile="${sampleDir}coverage/${genomeId}_coverage_graph.pdf"
					echo "<td><a href="$coverageFile">${genomeId}</a></td>" >> $result_blastn_page
					echo "</tr>" >> $result_blastn_page
			done < ${blastnResult}
		echo "</tbody>
		</table>
		<script src='http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js'></script>
		<script src='http://cdnjs.cloudflare.com/ajax/libs/jquery-throttle-debounce/1.1/jquery.ba-throttle-debounce.min.js'></script>
		<script src='js/jquery.stickyheader.js'></script>
	</body>
</html>" >> $result_blastn_page
