#!/usr/bin/env bash
#refgen is reference genome (.bim)
#genloc is location of genes
#pvalfile is the SNP/PVAL file
#genesets is the gene sets file
#outname is the output name
#myN is the sample number
homeDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "$(uname)" == "Darwin" ]; then
	magmaDir=$homeDir/magma_mac
else
	magmaDir=$homeDir/magma
fi

refgen=$1
genloc=$2
pvalfile=$3
genesets=$4
outname=$5
myN=$6
#example: 
#./doMAGMA.sh g1000.bim genloc pvalfile genesets outname 16731

filename=$(basename "$refgen")
extension="${filename##*.}"
refgenbis="${refgen%.*}"
window1=$7
window2=$8
$magmaDir --annotate window=$window1,$window2 --snp-loc ${refgen} --gene-loc ${genloc} --out ${outname} 
$magmaDir --bfile ${refgenbis} --pval ${pvalfile} N=${myN} --gene-annot ${outname}.genes.annot --gene-model multi=snp-wise --out ${outname} --gene-settings snp-min-maf=0.05 
$magmaDir --gene-results ${outname}.genes.raw --set-annot ${genesets} self-contained --out ${outname} 
awk '{if (f==1) {r[$1]=$5"\t"$6"\t"$8"\t"$9} else if (($1 in r)){print r[$1]"\t"$0}}' f=1 ${outname}.genes.out f=2 ${homeDir}/biomart_noLRG > ${outname}.genes.out.names
