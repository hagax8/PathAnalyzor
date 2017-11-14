#!/users/k1507306/R/bin/Rscript
arg <- commandArgs(TRUE) 

png(paste(arg[2],'.png',sep=""),width=1500,height=1500,res=300)

#mymat
mymat <- read.csv(arg[1], header=F, sep="\t")

computmat <- matrix(0,nrow(mymat),101)

xtitle <- as.character(arg[3])
ytitle <- as.character(arg[4])
nsamp=nrow(mymat)
#dx <- seq(0,1,by=0.2);
#dy <- seq(0,1,by=0.2);
#plot(vecx,vecy,cex.axis=1.5,cex.lab=1.5,pch=4,cex=1,xlab=xtitle,lty=1,ylab=ytitle, log ="y")
#plot(vecx,vecy,cex.axis=1.5,cex.lab=1.5,pch=4,cex=2,xlab=xtitle,lty=2,ylab=ytitle)
#abline(lm(vecy~vecx));
#legend("topright",  inset=c(-0.20,0), legend = c(" a " ," b ", " c "), pt.cex=3,y.intersp=1.5,cex=1.5,lty=c(1,2,3),text.font=2,lwd=thewidth)


thesum=sum(mymat[,3])

for(i in 1:10){
increm=mymat[1,i+2];
computmat[1,i]=increm/thesum;
for(j in 2:nrow(mymat)){
increm=increm+mymat[j,i+2]
computmat[j,i]=increm/thesum
}
}

par(mar=c(5.1, 6.1, 5.1, 2.5))

plot(as.vector(seq(from=1,to=nrow(mymat)))/nrow(mymat), computmat[,1], type="l",lwd=4.5,yaxt="n",xaxt="n",col="red",xlab=xtitle,ylab=ytitle,cex.lab=2,cex.axis=2,ann=FALSE)
#lines(computmat[,1])
mtext(side = 1, text = "% of ranked database", line = 3.5,cex=2)

mtext(side = 2, text = "% of antipsychotics found", line = 4.5,cex=2)

axis(2, at=pretty(computmat[,1]), lab=pretty(computmat[,1]) * 100, las=TRUE, cex.axis=1.6)
axis(1, at=c(0,0.20,0.40,0.60,0.80,1.0), lab=pretty(c(0,0.20,0.40,0.60,0.80,1.0)) * 100, las=TRUE, cex.axis=1.6)

#for(i in 2:101){
#lines(computmat[,i],col="blue")
#}


lines(c(0,100),c(0,100),col="blue",lwd=2)
y <- computmat[,1]
x <- as.vector(seq(from=1,to=nrow(mymat)))/nrow(mymat)
actual <- sum(diff(x) * (head(y,-1)+tail(y,-1)))/2
#x <- (x-min(x))/(max(x)-min(x))

#  = sqrt((SUM[x^2] - SUM[x]^2 / n) / (n-1))
set.seed(3)
sumx = 0
sumx2 = 0
myn=1000
myc=0
for(i in 1:myn){
#initvec<-as.vector(seq(from=1,to=nsamp))
#myrandvec <- sample(initvec,nsamp,replace=TRUE)
#sort(myrandvec)
#myrand <- mymat[myrandvec[],3]
set.seed(i)
myrand <- sample(mymat[,3],nsamp,replace=TRUE)
incremsamp=0
yamp<-vector(length=nsamp)
randsum=sum(myrand)
randomvec=as.vector(seq(from=1,to=nrow(mymat)))
for(j in 1:nsamp){
incremsamp=incremsamp+myrand[j]
yamp[j]=incremsamp/randsum
}

area <- sum(diff(x) * (head(yamp,-1)+tail(yamp,-1)))/2
write(area,'')
if(!is.na(area)){
#sumx = sumx+area;
#sumx2 = sumx2 + area*area;
myc <- myc + 1;
if(area>=actual){sumx = sumx+1}
}
}





#mymean = sumx/myc
#mysd = sqrt((sumx2 - (sumx^2)/myc) / (myc-1))

#write('Area Under Curve',"")
#require(Bolstad2)
#sintegral(x,y)$int
#actual <- sum(diff(x) * (head(y,-1)+tail(y,-1)))/2
#actual

#tomean<-vector(length=100)
#tocount=0

#for(i in 2:101){
#y <- computmat[,i]
#x <- as.vector(seq(from=1,to=nrow(mymat)))
#tomean[i-1] = sum(diff(x) * (head(y,-1)+tail(y,-1)))/2
#}

#themean <- mean(tomean)
#s <- sd(tomean)
#n <- 100
#error <- qnorm(0.975)*s/sqrt(n)

#write('Mean Random AUC:',"")
#themean

#write('IC error:',"")
#error

write('Normalized Area Under Curve',"")
#x <- (x-min(x))/(max(x)-min(x))
actual
#actual/nrow(mymat)

#z=(actual-0.5)/(mysd/sqrt(myc));
#pvalue2sided=2*pnorm(-abs(z))
wilci<-wilcox.test(mymat[,1] ~ mymat[,3],alternative="greater")
write('P-value',"")
#pval=(sumx)/(myc);
wilci$p.value
#write('Ustat',"")
#pval=(sumx)/(myc);
#1 - wilci$statistic / prod(table(mymat[,3]))
#pval=(sumx)/(myc);

#themean <- mean(tomean)
#s <- sd(tomean)
#n <- 100
#error <- qnorm(0.975)*s/sqrt(n)

#write('Mean Random AUC:',"")
#themean

#write('IC error:',"")
#error



dev.off(); 

