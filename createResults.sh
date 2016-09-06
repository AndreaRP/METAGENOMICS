set -e
#	GET PARAMETERS
sampleDir=$1  #/workingDir/ANALYSIS/xx-organism/sampleName/

#	INITIALIZE VARIABLES
sampleName=$(basename $sampleDir)
workingDir="$(echo $sampleDir | rev | cut -d'/' -f5- | rev)/" # 
organismDir=$(echo $sampleDir | rev | cut -d'/' -f3 | rev) # gets the 3 to last column (xx-organism)
organism="${organismDir##*-}" # gets what is after the '-' and assumes is the organism
blastnResult="${sampleDir}blast/${sampleName}_BLASTn_filtered.blast"
#blastxResult="${sampleDir}08.BLAST/VIRUS/${sampleName}_BLASTx.blast"
genomeId=""
coverageFile=""
result_blastn_page="${workingDir}/RESULTS/${sampleName}/blast.html"

mkdir -p "${workingDir}/RESULTS/${sampleName}/"

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
