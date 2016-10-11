#!/bin/bash
set -e

#########################################################
#	SCRIPT TO CREATE HTML PAGE WITH THE SAMPLE LIST		#
#########################################################
# 1. Gets the list of samples 
# 2. Creates the sample list
# Note: This script should only be run after the analysis is finished. 

# Arguments:
# $1 (workingDir) = Directory of the analysis. 

# Input Files: (In workingDir)
# samples_id.txt: File generated with samplesID_gen.sh

# Output files: (In RESULTS/)
# results.html: html file of with the sample list.


#	GET PARAMETERS
workingDir=$1  #
#		INPUT FILES
samplesId="${workingDir}ANALYSIS/samples_id.txt"
#		OUTPUT FILES
result_page="${workingDir}/RESULTS/samples.html"


echo "
<!DOCTYPE html>
<html lang='en' class='no-js'>
	<head>
		<meta charset='UTF-8' />
		<meta http-equiv='X-UA-Compatible' content='IE=edge'>
		<meta name='viewport' content='width=device-width, initial-scale=1'>
		<title>Metagenomic Analysis</title>
		<meta name='description' content='Metagenomic Analysis: Results report' />
		<meta name='keywords' content='metagenetics, metagenomics, ISCIII, bioinformatics' />
		<meta name='author' content='ISCIII Bioinformatics unit' />
		<link rel='stylesheet' type='text/css' href='css/normalize.css' />
		<link rel='stylesheet' type='text/css' href='css/deco.css' />
		<link rel='stylesheet' type='text/css' href='css/tabs.css' />
		<link rel='stylesheet' type='text/css' href='css/tabstyles.css' />
		<script src='js/jquery-3.1.0.js'></script>
		<script src='js/functionality.js'></script>
	</head>
	<body>
		<div class='container'>
			<!-- Top Navigation -->
			<header class='report-header'>
				<h1>Metagenomic Analysis <span>Results report</span></h1>
				<p class='support'>This browser doen't support<strong>flexbox</strong>! <br />To correctly view this report, please use an <strong>updated browser</strong>.</p>
			</header>
			<div id='contenido'>
				<div class='tabs tabs-style-bar'>
					<nav>
						<ul id = 'horizontal-nav'>
							<li><a href='resumen.html' class='icon icon-home'><span>Summary</span></a></li>
							<li class='tab-current'><a href='muestra.html' class='icon icon-display'><span>Per Sample</span></a></li>
							<li><a href='calidad.html' class='icon icon-upload'><span>Quality analysis</span></a></li>
							<li><a href='info.html' class='icon icon-book'><span>What is this?</span></a></li>
						</ul>
					</nav>
					</div><!-- /tabs -->
				
				<div id = 'pagina' class='content-wrap'>
					<div class='items vertical-nav'>
					<nav>
						<ul>" > $result_page
				#	Start formatting data
				cat $samplesId | while read in
				do
				  #  awk -v sample=${in} 'BEGIN {printf "%-9s\n",
				  #  "<li><a class='\''icon menu'\'' href='\''#sample'\''><span>'${in}'</span></a>",
				  #  	"<ul class='\''submenu'\''>",
				  #  		"<li><a href='\''#sample'\''><span>Bacteria</span></a></li>",
				  #  		"<li><a href='\''#sample'\''><span>Virus</span></a></li>",
				  #  		"<li><a href='\''#sample'\''><span>Fungi</span></a></li>",
				  #  		"<li><a href='\''#sample'\''><span>Protozoa</span></a></li>",
				  #  		"<li><a href='\''#sample'\''><span>Invertebrate</span></a></li>",
				  #  	"</ul>",
				  #  "</li>"}' >> $result_page
					
					 echo "
					 <li><a class='icon menu' href='""" >> $result_page
					 echo $in >> $result_page
					 echo "'><span>">> $result_page
					 echo $in >> $result_page
					 echo "</span></a>
					 <ul class='submenu'>
					 	<li><a class='icon-bacteria' href='#${in}'><span>Bacteria</span></a></li>
					 	<li><a class='icon-virus' href='#${in}'><span>Virus</span></a></li>
					 	<li><a class='icon-fungi' href='#${in}'><span>Fungi</span></a></li>
					 	<li><a class='icon-protozoo' href='#${in}'><span>Protozoa</span></a></li>
					 	<li><a class='icon-invertebrate' href='#${in}'><span>Invertebrate</span></a></li>
					 </ul>
					 </li>" >> $result_page
				done
				echo "</ul>
					</nav>
					</div>
					<object class="results" type="text/html" data=""></object>
					</div>
				</div><!-- /tabs -->
			<footer class='web-footer'>
				<div>
				<p> Icons made by 
					<a href='http://www.flaticon.com/authors/freepik' title='Freepik'>Freepik</a> 
					from <a href='http://www.flaticon.com' title='Flaticon'>www.flaticon.com</a> 
					is licensed by <a href='http://creativecommons.org/licenses/by/3.0/' title='Creative Commons BY 3.0' target='_blank'>CC 3.0 BY</a>
				</p>
			</div>
		</footer>
		</div>
	</body>
</html>" >> $result_page
