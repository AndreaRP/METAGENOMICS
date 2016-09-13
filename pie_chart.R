library(ggplot2)


df = read.table('percentageFile.txt',sep='\t',row.names=1)
#transponemos la tabla
por_org=t(df)
rownames(por_org) <- c("bacteria","virus","fungi","protozoa","invertebrate","NA")
# por cada muestra queremos generar un grafico
for(i in ncol(por_org)){
	sample=
p = ggplot(data=por_org[,i], aes(x=factor(1),y=colsum([r(2,3,4,5,6),]), fill = factor(organism)),)
}
