#!/bin/bash
set -e

#########################################################
#	SCRIPT TO CREATE HTML PAGE WITH THE SAMPLE LIST		#
#########################################################
# 1. Creates necessary directories. 
# 2. Generates html with the merged table.
# Note: This script should only be run after running mergeResults.R. 

# Arguments:
# $1 (sampleDir) = Directory of the organism analysis of the sample. (ANALYSIS/xx-organism/sampleName/)

# Input Files: (In RESULTS/data/)
# sampleName_organism_results.txt: File generated with mergeResults.R

# Output files: (In RESULTS/data/)
# sampleName_organism_results.html: html file of the merged results table.


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
		<title>Análisis metagenómico</title> 
		<meta name='description' content='Análisis metagenómico: Informe de resultados' />
		<meta name='keywords' content='metagenetica, metagenomica, ISCIII, bioinformática' />
		<meta name='author' content='Unidad Bioinformática ISCIII' />
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
				<h1>Análisis metagenómico <span>Informe de resultados</span></h1>
				<p class='support'>Este navegador no soporta <strong>flexbox</strong>! <br />Por favor, abra este informe con un <strong>navegador actualizado</strong>.</p>
			</header>
			<div id='contenido'>
				<div class='tabs tabs-style-bar'>
					<nav>
						<ul id = 'horizontal-nav'>
							<li class='tab-current'><a href='resumen.html' class='icon icon-home'><span>Resumen</span></a></li>
							<li><a href='muestra.html' class='icon icon-display'><span>Por muestra</span></a></li>
							<li><a href='calidad.html' class='icon icon-upload'><span>Análisis de calidad</span></a></li>
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
					echo "
					<li><a class='icon menu' href='#" >> $result_page
					echo $in >> $result_page
					echo "'><span>">> $result_page
					echo $in >> $result_page
					echo "</span></a></li>" >> $result_page
				done
				echo "</ul>
					</nav>
					</div>
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
