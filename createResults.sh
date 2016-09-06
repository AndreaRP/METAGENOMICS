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
   		<link rel='stylesheet' type='text/css' href='style.css'>
   	 	<meta content=''>
	</head>
	<body>
		<table class='flatTable'>
	   		<tr class='titleTr'>
				<td class='titleTd'> " >> $result_blastn_page
				echo "${sampleName} blast result" >> $result_blastn_page
				echo "				
				</td>
				<td colspan='4'></td>
				<td class='plusTd button'></td>
			</tr>
			<!-- <tr class='headingTr'> -->
			<thead class='headingTr'>
				<td>Subject Title</td>
				<td>Query Seq-id</td>
				<td>Reference Id</td>
				<td>Percentage of identical matches</td>
				<td>Alignment length</td>
				<td>Number of mismatches</td>
				<td>Number of gap openings</td>
				<td>Start of alignment in query</td>
				<td>End of alignment in query</td>
				<td>Start of alignment in subject</td>
				<td>End of alignment in subject</td>
				<td>Expect value</td>
				<td>Bit score</td>
				<td>Genome coverage</td>
			</thead>" >> $result_blastn_page
			#	Start formatting data from blast
			while IFS='' read -r line || [[ -n $line ]]
			do
				echo "
			<tr>" >> $result_blastn_page
				IFS='	' read -r -a array <<< "$line"
				for value in "${array[@]:0:13}"
				do
					echo "<td>${value}</td>" >> $result_blastn_page
				done
				# conseguir el genome id
				genomeId="${array[2]}"
				coverageFile="${sampleDir}coverage/${genomeId}_coverage_graph.pdf"
				echo "<td><a href="$coverageFile">${genomeId}</a></td>" >> $result_blastn_page
				echo "
      		</tr>
      		<!--
				<td class='controlTd'>
	  				<div class='settingsIcons'>
	    				<span class='settingsIcon'><img src='http://i.imgur.com/nnzONel.png' alt='X' /></span>
	    				<span class='settingsIcon'><img src='http://i.imgur.com/UAdSFIg.png' alt='placeholder icon' /></span>
	    				<div class='settingsIcon'><img src='http://i.imgur.com/UAdSFIg.png' alt='placeholder icon' /></div>
	  				</div>  
				</td>
			-->
      		</tr>" >> $result_blastn_page
		done < ${blastnResult}
			echo "
		</table>
	</body>
</html>" >> $result_blastn_page
