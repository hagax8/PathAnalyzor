#!/users/k1507306/R/bin/Rscript
arg <- commandArgs(TRUE)

mymat <- read.csv(arg[1],header=F,sep="\t")

mymat$q_value <- p.adjust(mymat[,as.numeric(arg[2])],method="BH")

#mymat$NAME <- as.character(mymat$NAME)

write.table(mymat,arg[1],row.names=F,col.names=T,quote=F,sep="\t")
