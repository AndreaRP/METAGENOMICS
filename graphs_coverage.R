library(ggplot2)
library(RColorBrewer)
library(plyr)

# leemos el archivo de bedtools
df=read.table("/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/ANALYSIS/06-virus/Unai-16/coverage/Unai-16_genome_coverage.txt", sep="\t")
# damos nombre a las columnas
colnames(df) <- c("gnm","covThreshold","fractionAtThisCoverage","genomeLength","diffFracBelowThreshold")
# df: 
# gnm			covThreshold	fractionAtThisCoverage	genomeLength	diffFracBelowThreshold
# NC_006641.1	0				15865					15959			0.99411
# NC_006641.1	1				94						15959			0.00589009
# NC_003216.1	0				40515					40834			0.992188
# ...

# generamos una nueva tabla en la que se agrupa por genoma y se calcula en cada cobertura el % de pb que se encentran a entre esa cobertura y la máxima (1-cumsum(diffFracBelowThreshold))
cov <- ddply(df,.(gnm),summarize,covThreshold=covThreshold,fracAboveThreshold=1-cumsum(diffFracBelowThreshold))
# cov:
#         gnm covThreshold fracAboveThreshold
# AC_000001.1            5               0.60  -> en el genoma AC_000001.1 hay un 60% de pb que están a una profundidad >= 5
# AC_000001.1            7               0.33  -> en el genoma AC_000001.1 hay un 33% de pb que están a una profundidad >= 7
# AC_000003.1            0               0
# AC_000002.1            4               0.17  -> en el genoma AC_000002.1 hay un 17% de pb que están a una profundidad >= 4
# ...

# generamos una nueva tabla agrupada por genoma con la media, min, max, sd y mediana de cada uno
new_cov <- ddply(cov,.(gnm),summarize,covMean=mean(covThreshold),covMin=min(covThreshold),covMax=max(covThreshold),covSD=sd(covThreshold),covMedian=median(covThreshold))
# new_cov:
# gnm 			covMean covMin    covMax covSD 		covMedian
# AC_000001.1       250      0      500    217        123
# AC_000002.1       100      0      200    78         98
# AC_000003.1       0        0      0      NA         0
# AC_000004.1       500      0      1000   98         843

#se agrupa por gnm y se saca el valor que corresponde a cobertura >1, >5, >10 y >20 (en columnas)
summary_cov <- by(cov, cov[,"gnm"], function(x) x$fracAboveThreshold[x$covThreshold==1 | x$covThreshold==5 | x$covThreshold==10 | x$covThreshold==20])
#convierte una lista en matriz
summary_cov <- do.call(rbind,summary_cov)
#damos nombre a las columnas
colnames(summary_cov) <- c("x1","x5","x10","x20")
# summary_cov:
# gnm       	  x1          x5          x10         x20
# AC_000001.1	0.8869967	0.7844005	0.7025351	0.60814771
# AC_000002.1   0.280761	0.1780007	0.13370223	0.0825864199999999
# AC_000004.1   0.269992	0.1507732	0.11396872	0.08871942
#junto los dos dataframes
cov_def <- cbind(new_cov[new_cov$covMean > 0,],summary_cov)
#cov_def:
# gnm           covMean covMin    covMax covSD      covMedian  x1          x5          x10         x20
# AC_000001.1       250      0      500    217        123		0.8869967	0.7844005	0.7025351	0.60814771
# AC_000002.1       100      0      200    78         98        0.280761	0.1780007	0.13370223	0.0825864199999999
# AC_000004.1       500      0      1000   98         843       0.269992	0.1507732	0.11396872	0.08871942
write.table(cov_def, file="coverageTable.txt",sep="\t",row.names=F)

# Plot the data. 
# mientras la cobertura sea menor que el máximo que he puesto (500) y por cada id_gnm (cada genoma)
# p1<-ggplot(subset(cov, covThreshold<maxCov & gnm == 'AC_000007.1'), aes(x= covThreshold, y=100* fracAboveThreshold)) +
# Agrupamos por gnm de cov y aplicamos la funcion a ese subset (g)
by(cov, cov[,"gnm"], function(g) {
	maxCov=500 # la máxima profundidad que se va a mostrar es 500 porque si no queda feo
   	#comprobamos que no esté vacío
    if (mean(g$covThreshold)!=0){
   		p1<-ggplot(subset(g, covThreshold<maxCov),aes(x=covThreshold, y=100*fracAboveThreshold)) +
		geom_line() + 
		ylim(0, 100) + 
		theme_bw() +
		theme(axis.text.x = element_text(size = 10.5,angle=75, vjust=0.5), strip.text.x = element_text(size=6.5)) + 
		labs(title=paste(g$gnm[1],"genome coverage", sep=' '), x="Depth of coverage", y="Percentage of coverage") 
		pdf(file=paste(g$gnm[1],"coverage_graph.pdf",sep='_'),width=15) 
		print(p1) 
		dev.off()
	}
	}
)
