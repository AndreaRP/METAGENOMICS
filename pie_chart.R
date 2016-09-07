library(ggplot2)


df = read.table('percentageFile.txt',sep='\t')
#transponemos la tabla
por_org=t(df)
rownames(por_org) <- c("organism","bacteria","virus","fungi","protozoa","invertebrate")
# por cada muestra queremos generar un grafico
p = ggplot(data=por_org[,1], aes(x=factor(1),y=colsum([r(2,3,4,5,6),]), fill = factor(organism)),)
