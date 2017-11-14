#!/users/k1507306/R/bin/Rscript

library(lattice)
arg <- commandArgs(TRUE)


qqunif.plot<-function(pvalues,
         should.thin=T, thin.obs.places=2, thin.exp.places=2,
         xlab=list(label=expression(paste("Expected (",-log[10], " p-value)")),cex=2),
         ylab=list(label=expression(paste("Observed (",-log[10], " p-value)")),cex=2),
         draw.conf=TRUE, conf.points=1000, conf.col="lightgray", conf.alpha=.05,
         already.transformed=FALSE, pch=20, aspect="iso", prepanel=prepanel.qqunif,
         par.settings=list(superpose.symbol=list(pch=pch)), ...) {


         #error checking
         if (length(pvalues)==0) stop("pvalue vector is empty, can't draw plot")
         if(!(class(pvalues)=="numeric" ||
                 (class(pvalues)=="list" && all(sapply(pvalues, class)=="numeric"))))
                 stop("pvalue vector is not numeric, can't draw plot")
         if (any(is.na(unlist(pvalues)))) stop("pvalue vector contains NA values, can't draw plot")
         if (already.transformed==FALSE) {
                 if (any(unlist(pvalues)==0)) stop("pvalue vector contains zeros, can't draw plot")
         } else {
                 if (any(unlist(pvalues)<0)) stop("-log10 pvalue vector contains negative values, can't draw plot")
         }


         grp<-NULL
         n<-1
         exp.x<-c()
         if(is.list(pvalues)) {
                 nn<-sapply(pvalues, length)
                 rs<-cumsum(nn)
                 re<-rs-nn+1
                 n<-min(nn)
                 if (!is.null(names(pvalues))) {
                         grp=factor(rep(names(pvalues), nn), levels=names(pvalues))
                         names(pvalues)<-NULL
                 } else {
                         grp=factor(rep(1:length(pvalues), nn))
                 }
                 pvo<-pvalues
                 pvalues<-numeric(sum(nn))
                 exp.x<-numeric(sum(nn))
                 for(i in 1:length(pvo)) {
                         if (!already.transformed) {
                                 pvalues[rs[i]:re[i]] <- -log10(pvo[[i]])
                                 exp.x[rs[i]:re[i]] <- -log10((rank(pvo[[i]], ties.method="first")-.5)/nn[i])
                         } else {
                                 pvalues[rs[i]:re[i]] <- pvo[[i]]
                                 exp.x[rs[i]:re[i]] <- -log10((nn[i]+1-rank(pvo[[i]], ties.method="first")-.5)/(nn[i]+1))
                         }
                 }
         } else {
                 n <- length(pvalues)+1
                 if (!already.transformed) {
                         exp.x <- -log10((rank(pvalues, ties.method="first")-.5)/n)
                         pvalues <- -log10(pvalues)
                 } else {
                         exp.x <- -log10((n-rank(pvalues, ties.method="first")-.5)/n)
                 }
         }


         #this is a helper function to draw the confidence interval
         panel.qqconf<-function(n, conf.points=1000, conf.col="gray", conf.alpha=.05, ...) {
                 require(grid)
                 conf.points = min(conf.points, n-1);
                 mpts<-matrix(nrow=conf.points*2, ncol=2)
                 for(i in seq(from=1, to=conf.points)) {
                         mpts[i,1]<- -log10((i-.5)/n)
                         mpts[i,2]<- -log10(qbeta(1-conf.alpha/2, i, n-i))
                         mpts[conf.points*2+1-i,1]<- -log10((i-.5)/n)
                         mpts[conf.points*2+1-i,2]<- -log10(qbeta(conf.alpha/2, i, n-i))
                 }
                 grid.polygon(x=mpts[,1],y=mpts[,2], gp=gpar(fill=conf.col, lty=0), default.units="native")
         }

         #reduce number of points to plot
         if (should.thin==T) {
                 if (!is.null(grp)) {
                         thin <- unique(data.frame(pvalues = round(pvalues, thin.obs.places),
                                 exp.x = round(exp.x, thin.exp.places),
                                 grp=grp))
                         grp = thin$grp
                 } else {
                         thin <- unique(data.frame(pvalues = round(pvalues, thin.obs.places),
                                 exp.x = round(exp.x, thin.exp.places)))
                 }
                 pvalues <- thin$pvalues
                 exp.x <- thin$exp.x
         }
         gc()

         prepanel.qqunif= function(x,y,...) {
                 A = list()
                 A$xlim = range(x, y)*1.02
                 A$xlim[1]=0
                 A$ylim = A$xlim
                 return(A)
         }

         #draw the plotscales=list(axs="i")
         xyplot(pvalues~exp.x, groups=grp, xlab=xlab, ylab=ylab, aspect=aspect,
                 prepanel=prepanel, scales=list(tck=c(1,0), x=list(cex=2), y=list(cex=2)), pch=pch,
                 panel = function(x, y, ...) {
                         if (draw.conf) {
                                 panel.qqconf(n, conf.points=conf.points,
                                         conf.col=conf.col, conf.alpha=conf.alpha)
                         };
                         panel.xyplot(x,y,...);
                         panel.abline(0,1);
                 }, par.settings=par.settings, ...
         )
 }

P <- read.table(arg[1],header=T,sep="\t")[,1]

pdf(paste(arg[2],'_qq_conf.pdf',sep=""),width=10,height=10,useDingbats=F)
qqunif.plot(P)
garbage<-dev.off()
detach("package:lattice",unload=TRUE)
garbage<-library(qqman,verbose=FALSE)

pdf(paste(arg[2],'_qq.pdf',sep=""),width=10,height=10,useDingbats=F)
par(mar=c(5.1,5.1,4.1,2.1))
qq(as.numeric(P),cex=1.5,cex.axis=1.5,cex.lab=1.5)
garbage<-dev.off()
