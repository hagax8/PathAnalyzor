#!/users/k1507306/R/bin/Rscript
garbage<-library(MASS)
garbage<-library(grid)
garbage<-library(calibrate)
garbage<-library(lattice)
garbage<-library(ggplot2)
arg <- commandArgs(TRUE)

#manhattanf was imported from qqman R package
#qqunif was imported from gap R package

manhattanf <- function(x, chr="CHR", bp="BP", p="P", snp="SNP", 
                      col=c("gray10", "gray60"), chrlabs=NULL,
                      suggestiveline=-log10(1e-5), genomewideline=-log10(5e-8), 
                      highlight=NULL, logp=TRUE, annotatePval = NULL, annotateTop = TRUE, ...) {

    # Not sure why, but package check will warn without this.
    CHR=BP=P=index=NULL
    
    # Check for sensible dataset
    ## Make sure you have chr, bp and p columns.
    if (!(chr %in% names(x))) stop(paste("Column", chr, "not found!"))
    if (!(bp %in% names(x))) stop(paste("Column", bp, "not found!"))
    if (!(p %in% names(x))) stop(paste("Column", p, "not found!"))
    ## warn if you don't have a snp column
    if (!(snp %in% names(x))) warning(paste("No SNP column found. OK unless you're trying to highlight."))
    ## make sure chr, bp, and p columns are numeric.
    if (!is.numeric(x[[chr]])) stop(paste(chr, "column should be numeric. Do you have 'X', 'Y', 'MT', etc? If so change to numbers and try again."))
    if (!is.numeric(x[[bp]])) stop(paste(bp, "column should be numeric."))
    if (!is.numeric(x[[p]])) stop(paste(p, "column should be numeric."))
    
    # Create a new data.frame with columns called CHR, BP, and P.
    d=data.frame(CHR=x[[chr]], BP=x[[bp]], P=x[[p]])
    
    # If the input data frame has a SNP column, add it to the new data frame you're creating.
    if (!is.null(x[[snp]])) d=transform(d, SNP=x[[snp]])
    
    # Set positions, ticks, and labels for plotting
    ## Sort and keep only values where is numeric.
    #d <- subset(d[order(d$CHR, d$BP), ], (P>0 & P<=1 & is.numeric(P)))
    d <- subset(d, (is.numeric(CHR) & is.numeric(BP) & is.numeric(P)))
    d <- d[order(d$CHR, d$BP), ]
    #d$logp <- ifelse(logp, yes=-log10(d$P), no=d$P)
    if (logp) {
        d$logp <- -log10(d$P)
    } else {
        d$logp <- d$P
    }
    d$pos=NA
    
    
    # Fixes the bug where one chromosome is missing by adding a sequential index column.
    d$index=NA
    ind = 0
    for (i in unique(d$CHR)){
        ind = ind + 1
        d[d$CHR==i,]$index = ind
    }
    
    # This section sets up positions and ticks. Ticks should be placed in the
    # middle of a chromosome. The a new pos column is added that keeps a running
    # sum of the positions of each successive chromsome. For example:
    # chr bp pos
    # 1   1  1
    # 1   2  2
    # 2   1  3
    # 2   2  4
    # 3   1  5
    nchr = length(unique(d$CHR))
    if (nchr==1) { ## For a single chromosome
        ## Uncomment the next two linex to plot single chr results in Mb
        #options(scipen=999)
	    #d$pos=d$BP/1e6
        d$pos=d$BP
        ticks=floor(length(d$pos))/2+1
        xlabel = paste('Chromosome',unique(d$CHR),'position')
        labs = ticks
    } else { ## For multiple chromosomes
        lastbase=0
        ticks=NULL
        for (i in unique(d$index)) {
            if (i==1) {
                d[d$index==i, ]$pos=d[d$index==i, ]$BP
            } else {
                lastbase=lastbase+tail(subset(d,index==i-1)$BP, 1)
                d[d$index==i, ]$pos=d[d$index==i, ]$BP+lastbase
            }
            # Old way: assumes SNPs evenly distributed
            # ticks=c(ticks, d[d$index==i, ]$pos[floor(length(d[d$index==i, ]$pos)/2)+1])
            # New way: doesn't make that assumption
            ticks = c(ticks, (min(d[d$index == i,]$pos) + max(d[d$index == i,]$pos))/2 + 1)
        }
        xlabel = 'Chromosome'
        #labs = append(unique(d$CHR),'') ## I forgot what this was here for... if seems to work, remove.
        labs <- unique(d$CHR)
    }
    
    # Initialize plot
    xmax = ceiling(max(d$pos) * 1.03)
    xmin = floor(max(d$pos) * -0.03)
    
    # The old way to initialize the plot
    # plot(NULL, xaxt='n', bty='n', xaxs='i', yaxs='i', xlim=c(xmin,xmax), ylim=c(ymin,ymax),
    #      xlab=xlabel, ylab=expression(-log[10](italic(p))), las=1, pch=20, ...)

    
    # The new way to initialize the plot.
    ## See http://stackoverflow.com/q/23922130/654296
    ## First, define your default arguments
    def_args <- list(xaxt='n', bty='n', xaxs='i', yaxs='i', las=1, pch=20,
                     xlim=c(xmin,xmax), ylim=c(0,ceiling(max(d$logp))),
                     xlab=xlabel, ylab=expression(-log[10](italic(p))))
    ## Next, get a list of ... arguments
    #dotargs <- as.list(match.call())[-1L]
    dotargs <- list(ann=F)
    ## And call the plot function passing NA, your ... arguments, and the default
    ## arguments that were not defined in the ... arguments.
    do.call("plot", c(NA, dotargs, def_args[!names(def_args) %in% names(dotargs)]))
     mtext(side = 2, text = expression(-log[10](italic(p))), line = 2,cex=0.85)
    # If manually specifying chromosome labels, ensure a character vector and number of labels matches number chrs.
    if (!is.null(chrlabs)) {
        if (is.character(chrlabs)) {
            if (length(chrlabs)==length(labs)) {
                labs <- chrlabs
            } else {
                warning("You're trying to specify chromosome labels but the number of labels != number of chromosomes.")
            }
        } else {
            warning("If you're trying to specify chromosome labels, chrlabs must be a character vector")
        }
    }
    
    # Add an axis. 
    if (nchr==1) { #If single chromosome, ticks and labels automatic.
        axis(1, ...)
    } else { # if multiple chrs, use the ticks and labels you created above.
       # axis(1, at=ticks, labels=labs, ...)
	axis(1,at=ticks,labels=FALSE)
	text(ticks, par("usr")[3] - 0.4, labels = labs, srt = 0, pos = 1, xpd = TRUE,cex=0.8)
    }
     
    # Create a vector of alternatiting colors
    col=rep(col, max(d$CHR))

    # Add points to the plot
    if (nchr==1) {
        with(d, points(pos, logp, pch=20, col=col[1], ...))
    } else {
        # if multiple chromosomes, need to alternate colors and increase the color index (icol) each chr.
        icol=1
        for (i in unique(d$index)) {
            with(d[d$index==unique(d$index)[i], ], points(pos, logp, col=col[icol], pch=20, ...))
            icol=icol+1
        }
    }
    
    # Add suggestive and genomewide lines
    if (suggestiveline) abline(h=suggestiveline, col="blue")
    if (genomewideline) abline(h=genomewideline, col="red")
    
    # Highlight snps from a character vector
    if (!is.null(highlight)) {
        if (any(!(highlight %in% d$SNP))) warning("You're trying to highlight SNPs that don't exist in your results.")
        d.highlight=d[which(d$SNP %in% highlight), ]
        with(d.highlight, points(pos, logp, col="green3", pch=20, ...)) 
    }
    
    # Highlight top SNPs
    if (!is.null(annotatePval)) {
        # extract top SNPs at given p-val
        topHits = subset(d, P <= annotatePval)
        par(xpd = TRUE)
        # annotate these SNPs
        if (annotateTop == FALSE) {
            with(subset(d, P <= annotatePval), 
                 textxy(pos, -log10(P), offset = 0.625, labs = topHits$SNP,cex=1), ...)
        }
        else {
            # could try alternative, annotate top SNP of each sig chr
            topHits <- topHits[order(topHits$P),]
            topSNPs <- NULL
            
            for (i in unique(topHits$CHR)) {
                
                chrSNPs <- topHits[topHits$CHR == i,]
                topSNPs <- rbind(topSNPs, chrSNPs[1,])
#		if (!is.na(chrSNPs[2,1])) {topSNPs <- rbind(topSNPs, chrSNPs[2,])}
#		if (!is.na(chrSNPs[3,1])) {topSNPs <- rbind(topSNPs, chrSNPs[3,])}
            }
             textxy(topSNPs$pos, -log10(topSNPs$P), offset = 0.625, labs = topSNPs$SNP, cex=1,  ...)
        }
    }  
    par(xpd = FALSE)
}
 

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





gres <- read.table(arg[1],header=F,sep="\t")[,]
colnames(gres) <- c("CHR","BP","SNP","P")
gres$P <- as.numeric(as.character(gres$P))
#gres$P[gres$P<1E-20]<- 1E-20
gres <- as.data.frame(gres)
suggest=(0.5/length(gres$SNP))
genomewide=(0.05/length(gres$SNP))

chrlabs=c(1:22,"X")

pdf(paste(arg[2],'.pdf',sep=""),onefile=T,width = 8.3, height = 11.7)
#par(mar=c(2,2,2,2))
par(omi = rep(.1,4))
#par(omi=rep(0.5,4))
layout(matrix(c(1,1,1,2,2,2,3,4,4), 3, 3, byrow = TRUE),widths=c(2,1,1), heights=c(1,1,1))
manhattanf(gres,cex.lab=1,suggestiveline=-log10(suggest),genomewideline=-log10(genomewide),xlab="",cex.axis=1,annotatePval=suggest,annotateTop=TRUE,las=2);
title("Gene Manhattan Plot with Top Significant Gene per Chromosome")
manhattanf(gres,cex.lab=1,suggestiveline=-log10(suggest),genomewideline=-log10(genomewide),xlab="",cex.axis=1,las=2);
title("Gene Manhattan Plot")
garbage<-detach("package:lattice",unload=TRUE)
garbage<-library(qqman,verbose=FALSE)
#plot(1, type="n", axes=F, xlab="", ylab="")
par(mar=c(7,7,2.1,3.1))
qq(as.numeric(gres$P),cex=1,cex.axis=1,cex.lab=1);
title("Gene Q-Q Plot")
newdata <- gres[order(gres$P),] 
par(mar=c(5,9,2.1,3.1))
mypalette<-heat.colors(23) 
bplt<-barplot(rev(-log10(newdata$P[1:20])), horiz=TRUE, names.arg=rev(paste(newdata$SNP[1:20]," (",newdata$CHR[1:20],")",sep="")), cex.names=1.1,las=1)
#text(x=rev(-log10(newdata$P[1:20]))*1.05, y= bplt, labels=as.character(round(rev(-log10(newdata$P[1:20])),1)), xpd=TRUE)
#plot(1, type="n", axes=F, xlab="", ylab="")
title(expression(-Log[10](italic(p))~"for"~the~Top~"20"~Genes))
shortdata<-rev(newdata[1:50,])
g <- ggplot(shortdata, aes(reorder(SNP,-log10(P)), y=-log10(P),fill=-log10(P)))
g + geom_bar(stat="identity") + scale_y_continuous() + scale_fill_gradient(name=expression(-Log[10](italic(p))),low='blue',  high='red', space='Lab') + coord_flip() + xlab("Gene") + ylab(expression(-Log[10](italic(p)))) 
garbage<-detach("package:qqman",unload=TRUE)
garbage <- library(lattice)
garbage<-dev.off()


#pdf(paste(arg[2],'_manhattan_annot.pdf',sep=""),useDingbats=F,width=25)
#par(mar=c(5.1,5.5,4.1,2.1))
#manhattanf(gres,cex.lab=2,suggestiveline=-log10(suggest),genomewideline=-log10(genomewide),xlab="",cex.axis=2,annotatePval=genomewide,annotateTop=TRUE,las=2)
#garbage<-dev.off()
#
#pdf(paste(arg[2],'_manhattan.pdf',sep=""),useDingbats=F,width=25)
#par(mar=c(5.1,5.5,4.1,2.1))
#manhattanf(gres,cex.lab=2,suggestiveline=-log10(suggest),genomewideline=-log10(genomewide),xlab="",cex.axis=2,las=2)
#garbage<-dev.off()
#
#
#pdf(paste(arg[2],'_qq_conf.pdf',sep=""),width=10,height=10,useDingbats=F)
#par(mar=c(5.1,5.1,4.1,2.1))
#qqunif.plot(gres$P)
#garbage<-dev.off()
#
#garbage<-detach("package:lattice",unload=TRUE)
#garbage<-library(qqman,verbose=FALSE)
#
#pdf(paste(arg[2],'_qq.pdf',sep=""),width=10,height=10,useDingbats=F)
#par(mar=c(5.1,5.1,4.1,2.1))
#qq(as.numeric(gres$P),cex=2,cex.axis=2,cex.lab=2)
#garbage<-dev.off()
#

#garbage<-detach("package:qqman",unload=TRUE)
#garbage <- library(lattice)

#png(paste(arg[2],'_manhattan_annot.png',sep=""),width=3500,height=1500,res=300)
#par(mar=c(5.1,5.5,4.1,2.1))
#manhattanf(gres,cex.lab=1,suggestiveline=-log10(suggest),genomewideline=-log10(genomewide),xlab="",cex.axis=2,annotatePval=genomewide,annotateTop=TRUE,las=2)
#garbage<-dev.off()
#

#png(paste(arg[2],'_manhattan.png',sep=""),width=3500,height=1500,res=300)
#par(mar=c(5.1,5.5,4.1,2.1))
#manhattanf(gres,cex.lab=1,suggestiveline=-log10(suggest),genomewideline=-log10(genomewide),xlab="",cex.axis=1,las=2)
#garbage<-dev.off()


#png(paste(arg[2],'_qq_conf.png',sep=""),width=1500,height=1500,res=300)
#qqunif.plot(gres$P,cex=0.5,cex.axis=0.5,cex.lab=0.5)
#garbage<-dev.off()

#garbage<-detach("package:lattice",unload=TRUE)
#garbage<-library(qqman,verbose=FALSE)

#png(paste(arg[2],'_qq.png',sep=""),width=1500,height=1500,res=300)
#par(mar=c(5.1,5.1,4.1,2.1))
#qq(as.numeric(gres$P),cex=1,cex.axis=1,cex.lab=1)
#garbage<-dev.off()

