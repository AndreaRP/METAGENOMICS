########################################################
#		  		SCRIPTS TO MERGE RESULTS			 	#
#########################################################
#
workingDir="/processing_Data/bioinformatics/research/20160530_METAGENOMICS_AR_IC_T/"

# get arguments
args = commandArgs(trailingOnly=TRUE)
sampleName=args[1] # sampleName
organism=args[2] # xx-organism
sampleCoverageTable=paste(workingDir, "ANALYSIS/", organism, "/", sampleName, "/coverage/", sampleName,"_coverageTable.txt", sep='')
sampleBlastTable=paste(workingDir, "ANALYSIS/", organism, "/", sampleName, "/blast/",sampleName, "_BLASTn_filtered.blast", sep= '')
# read files
coverage=read.table(sampleCoverageTable, sep="\t", header=TRUE)
blast=read.table(sampleBlastTable, sep="\t", header=FALSE)
# naming blast cols
colnames(blast) <- c("Organism","Query_seq_id","Reference Id","% of identical matches","Alignment length", "Number of mismatches", 
					 "Number of Gap openings", "Start of alignment in query", "End of alignment in query", "Start of alignment in subject", 
					 "Expect value", "Bit Score", "Query")
# dropping query id and query sequence
blast = subset(blast, select = c("Organism","Reference Id","% of identical matches","Alignment length", "Number of mismatches",
								 "Number of Gap openings", "Start of alignment in query", "End of alignment in query", "Start of alignment in subject",
								 "Expect value", "Bit Score"))
# merge files
sampleResults = merge(x=blast, y=coverage, by.x = "Reference Id", by.y = "gnm")
#writeTable
organism=unlist(strsplit(organism, split='-', fixed=TRUE))[2]
write.table(sampleResults, file=(paste(workingDir, "RESULTS/data/", sampleName, "_", organism, "_results.txt", sep="")), sep= '\t', row.names=FALSE)


