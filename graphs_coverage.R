library(ggplot2)
library(RColorBrewer)
library(plyr)
#brewer_qualitative <- c("#0000ff","#ff0000","#483215","#008900","#7244c4","#e65a11","#000000","#e6e528","#ff00ee","#6e0000","#00c7dd","#d4b455","#8f008d","#736b00","#7d8cbf","#c2a91b","#374a12")
# get file names
# Para cada genoma genero un histograma con la cobertura
print(files <- list.files(pattern="coverage.csv$"))

# load and parse the files
#cov_graph <- NULL
#for (f in files){
# 	df=read.table(f, sep="\t")
#	colnames(df) <- c("chr","covThreshold","fractionAtThisCoverage","ChrLength","diffFracBelowThreshold")
# 	cov <- ddply(df,.(chr),summarize,covThreshold=covThreshold,fracAboveThreshold=1-cumsum(diffFracBelowThreshold))
# 	cov_graph <- rbind(cov_graph,cbind(cov, sample= gsub("^([0-9a-zA-Z]+).*$", "\\1", f)))
#}
#
# plot the data
#maxCov=100
#
#p1<-ggplot(subset(cov_graph, covThreshold<maxCov & chr != "genome"), aes(x= covThreshold, y=100* fracAboveThreshold, color=sample)) +
#geom_line() + 
#ylim(0, 100) + 
#scale_color_manual(values=brewer_qualitative) +
#theme_bw() +
#theme(axis.text.x = element_text(size = 10.5,angle=75, vjust=0.5), strip.text.x = element_text(size=6.5)) + 
#labs(title="Genome Coverage", x="Depth of coverage", y="Percentage of coverage") +
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
#pdf(file="coverage_graph.pdf",width=15)
#print(p1)
#print(p2)
#dev.off()

