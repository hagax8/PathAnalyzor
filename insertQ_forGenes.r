#!/users/k1507306/R/bin/Rscript

arg <- commandArgs(TRUE)

mymat <- read.csv(arg[1],header=T,sep="\t")

mymat$q_valueBH <- p.adjust(mymat$P,method="BH")
mymat$q_valueBY <- p.adjust(mymat$P,method="BY")
mymat$p_valueBF <- p.adjust(mymat$P,method="bonferroni")
#qobj <- qvalue(p = mymat$COMP_P)
#mymat$qval <- qobj$qvalues
#mymat$NAME <- as.character(mymat$NAME)
#pdf(paste(arg[1],".p.pdf",sep=""))
#hist(mymat$COMP_P, nclass = 20)
#dev.off()
write.table(mymat,arg[1],row.names=F,col.names=T,quote=F,sep="\t")
