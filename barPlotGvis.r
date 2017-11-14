#!/users/k1507306/R/bin/Rscript


args <- commandArgs(TRUE) 

library(googleVis)
tt <- read.table(args[1], header=TRUE, sep="\t")[,]
supplierv <- tt$NAME
logPv <- round(-log10(as.numeric(tt$'COMP_P')),digits=2)
Pv <- tt$'COMP_P'
ngenes <- tt$NGENES
q_value <- tt$'q_valueBH'
logQv <- round(-log10(as.numeric(tt$'q_valueBH')),digits=2)
#namemat <- do.call('rbind',strsplit(as.character(supplierv), '?getlink?',fixed=TRUE))
myname <- as.character(tt$NAME)
mylink <- as.character(tt$LINK)

#lst <- unlist(strsplit(as.character(supplierv), '?getlink?',fixed=TRUE))
#namea<-unlist(lapply( strsplit(as.character(supplierv[[1]]),"\?getlink\?"), "[", 1))
#nameb<-unlist(lapply( strsplit(as.character(supplierv[[1]]),"\?getlink\?"), "[", 2))

P<-as.data.frame(cbind(logPv,Pv,ngenes,logQv,q_value,myname,mylink))
P[1:2,]

colnames(P)<-c('Log_COMP_P','COMP_P','ngenes','Log_COMP_Q','q_value','name','link')

foo <- paste('<a href = ', shQuote(P$link), ' target="_blank">', P$name, '</a>') 

dftable=data.frame(minus_log_p=as.numeric(as.character(P$Log_COMP_P)),minus_log_q=as.numeric(as.character(P$Log_COMP_Q)),pathway=foo,p=P$COMP_P,q=P$q_value,Ngenes=ngenes)

#dftable=transform(dftable, minus_log_p = as.numeric(as.character(minus_log_p)))
#dfbar=data.frame(supplier=P$name,pvalue=as.numeric(round(P$COMP_P,digits=2)))
#Bar1 <- gvisBarChart(df,xvar="supplier",yvar="pvalue",options=list(gvis.editor="Edit Chart",allowHTML=TRUE,height=500,chartArea="{left:300,top:5,bottom:150,width:\"100%\",height:\"100%\"}"))  
Bar1 <- gvisTable(dftable,options=list(allowHTML=TRUE,width="automatic",height="automatic"),formats=list(minus_log_p="#.####",minus_log_q="#.####"));
#Bar2 <- gvisBarChart(dfbar,xvar="supplier",yvar="pvalue",options=list(allowHTML=TRUE,gvis.editor="Edit",chartArea="{left:300,top:5,bottom:150,width:\"100%\",height:\"100%\"}"));

cat(Bar1$html$chart,file=args[2])
#cat(Bar2$html$chart,file=args[2])
