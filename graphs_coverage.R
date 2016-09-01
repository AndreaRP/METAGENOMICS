library(ggplot2)
library(RColorBrewer)
library(plyr)
#brewer_qualitative <- c("#0000ff","#ff0000","#483215","#008900","#7244c4","#e65a11","#000000","#e6e528","#ff00ee","#6e0000","#00c7dd","#d4b455","#8f008d","#736b00","#7d8cbf","#c2a91b","#374a12")
# get file names
# Para cada genoma genero un histograma con la cobertura
#print(files <- list.files(pattern="coverage.csv$"))
#print(files <- list.files(pattern="coverage.csv$"))
# load and parse the files
#cov_graph <- NULL
#for (f in files){
# 	df=read.table(f, sep="\t")
# leemos el archivo de bedtools
# df: 
# idGenoma		profundidad	pb a esa profundidad	genome length	% a esa profundidad
# NC_006641.1	0			15865					15959			0.99411
# NC_006641.1	1			94						15959			0.00589009
# NC_003216.1	0			40515					40834			0.992188
# ...
df=read.table("/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/ANALYSIS/06-virus/Unai-16/coverage/Unai-16_genome_coverage.txt", sep="\t")
# damos nombre a las columnas
colnames(df) <- c("gnm","covThreshold","fractionAtThisCoverage","genomeLength","diffFracBelowThreshold")

# generamos una nueva tabla en la que se agrupa por genoma y se calcula en cada cobertura el % de pb que se encentran a entre esa cobertura y la máxima (1-cumsum(diffFracBelowThreshold))
# Cov:
# Genoma1	5	0.60 -> en el genoma 1 hay un 60% de pb que están a una profundidad >= 5
# Genoma1	7	0.35 -> en el genoma 1 hay un 35% de pb que están a una profundidad >= 7
# ...
cov <- ddply(df,.(gnm),summarize,covThreshold=covThreshold,fracAboveThreshold=1-cumsum(diffFracBelowThreshold))

# generamos una nueva tabla agrupada por genoma con la media, min, max, sd y mediana de cada uno
new_cov <- ddply(cov,.(gnm),summarize,covMean=mean(covThreshold),covMin=min(covThreshold),covMax=max(covThreshold),covSD=sd(covThreshold),covMedian=median(covThreshold))

#se agrupa por gnm y se saca el valor que corresponde a cobertura >1, >5, >10 y >20 (en columnas)
summary_cov <- by(cov, cov[,"gnm"], function(x) x$fracAboveThreshold[x$covThreshold==1 | x$covThreshold==5 | x$covThreshold==10 | x$covThreshold==20])
 	#convierte una lista en matriz
 	summary_cov <- do.call(rbind,summary_cov)
 	#damos nombre a las columnas
 	colnames(summary_cov) <- c("x1","x5","x10","x20")
 	#junto los dos dataframes
 	cov_def <- cbind(new_cov[new_cov$covMean > 0,],summary_cov)
 	write.table(cov_def, file="coverageTable.txt",sep="\t",row.names=F)

# 	cov_graph <- rbind(cov_graph,cbind(cov, sample= gsub("^([0-9a-zA-Z]+).*$", "\\1", f)))
#}
#
# plot the data. Generar un bucle para que haga esto por cada linea de cov_def (== coverageTable.txt)
# mientras la cobertura sea menor que el máximo que he puesto (500) y por cada id_gnm (cada genoma)
#p1<-ggplot(subset(cov, covThreshold<maxCov & gnm == 'AC_000007.1'), aes(x= covThreshold, y=100* fracAboveThreshold)) +
by(cov, cov[,"gnm"], function(g) {
   	#comprobamos que no esté vacío
	maxCov=500 # la máxima profundidad que se va a mostrar es 500 porque si no queda feo
    if (mean(g$covThreshold)!=0){
   		p1<-ggplot(subset(g, covThreshold<maxCov),aes(x=covThreshold, y=100*fracAboveThreshold)) +
		geom_line() + 
		ylim(0, 100) + 
		#scale_color_manual(values=brewer_qualitative) +
		theme_bw() +
		theme(axis.text.x = element_text(size = 10.5,angle=75, vjust=0.5), strip.text.x = element_text(size=6.5)) + 
		labs(title=paste(g$gnm[1],"genome coverage", sep=' '), x="Depth of coverage", y="Percentage of coverage") 

		pdf(file=paste(g$gnm[1],"coverage_graph.pdf",sep='_'),width=15) 
		print(p1) 
		dev.off()
	}
	}
)
#print(p2)

#facet_wrap(~chr)
#
#p2<-ggplot(subset(cov_graph, covThreshold<maxCov & chr == "genome"), aes(x= covThreshold, y=100* fracAboveThreshold, color=sample)) + 
#geom_line() + 
#ylim(0, 100) + 
#scale_color_manual(values=brewer_qualitative) +
#theme_bw() +
#theme(axis.text.x = element_text(size = 10.5,angle=75, vjust=0.5), strip.text.x = element_text(size=6.5)) +
#labs(title="Genome Coverage", x="Depth of coverage", y="Percentage of coverage")
#
