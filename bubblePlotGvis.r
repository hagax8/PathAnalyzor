#!/users/k1507306/R/bin/Rscript


args <- commandArgs(TRUE) 

library(googleVis)

tt <- read.table(args[1], header=TRUE, sep="\t")[1:50,]
supplierv <- tt$NAME
logPv <- round(-log10(as.numeric(tt$COMP_P)),digits=2)
Pv <- as.character(tt$COMP_P)
ngenes <- tt$NGENES
q_value <- tt$q_valueBH
#namemat <- do.call('rbind',strsplit(as.character(supplierv), '?getlink?',fixed=TRUE))
name <- as.character(tt$NAME)
link <- as.character(tt$LINK)
logQv <- round(-log10(as.numeric(tt$q_valueBH)),digits=2)
P<-as.data.frame(cbind(logPv,Pv,ngenes,logQv,q_value,name,link))

colnames(P)<-c('Log_COMP_P','COMP_P','ngenes','Log_COMP_Q','q_value','name','link')
dftable=data.frame(geneset=as.character(P$name),minus_log_p=as.numeric(as.character(P$Log_COMP_P)),p=as.numeric(as.character(P$COMP_P)),q=as.numeric(as.character(P$q)),minus_log_q=as.numeric(as.character(P$Log_COMP_Q)),Ngenes=as.numeric(as.character(ngenes)))
#dfbar=data.frame(supplier=P$name,pvalue=as.numeric(round(P$COMP_P,digits=2)))
#Bar1 <- gvisBarChart(df,xvar="supplier",yvar="pvalue",options=list(gvis.editor="Edit Chart",allowHTML=TRUE,height=500,chartArea="{left:300,top:5,bottom:150,width:\"100%\",height:\"100%\"}"))  
Bubble <- gvisBubbleChart(dftable,idvar="geneset",xvar="Ngenes",yvar="minus_log_p",sizevar="minus_log_q",
options=list(gvis.editor="Edit Chart",allowHTML=TRUE,height=500,chartArea="{left:\"10%\",bottom:\"10%\",width:\"80%\",height:\"80%\"}",hAxis="{title:'Number of genes'}",vAxis="{title:'-log10(p-value)'}",
#colorAxis="{colors: [\'yellow\', \'red\']}"))
                           sizeAxis="{minSize:4, maxSize:4}",
                                displayMode='markers',
                                colorAxis="{colors:['blue', 'red']}"))

#Bubble <- gvisBubbleChart(dftable,
#,options=list(colorAxis="{colors: ['gray','gray']}",bubble="{textStyle:{color: 'black', fontName: 'Arial', fontSize: '8'},opacity:'0.2'}"))

cat(Bubble$html$chart,file=args[2])
#cat(Bar2$html$chart,file=args[2])
