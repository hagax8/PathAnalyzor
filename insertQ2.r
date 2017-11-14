#!/users/k1507306/R/bin/Rscript
arg <- commandArgs(TRUE)

mymat <- read.csv(arg[1],header=F,sep="\t")

mymat$q_value <- p.adjust(mymat[,1],method="BH")

write.table(mymat,arg[1],row.names=F,col.names=F,quote=F,sep="\t")
