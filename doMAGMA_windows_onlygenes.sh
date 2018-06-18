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
outname=$4
myN=$5
#example: 
#./doMAGMA.sh g1000.bim genloc pvalfile outname 16731

filename=$(basename "$refgen")
extension="${filename##*.}"
refgenbis="${refgen%.*}"
window1=$6
window2=$7
$magmaDir --annotate window=$window1,$window2 --snp-loc ${refgen} --gene-loc ${genloc} --out ${outname} 
$magmaDir --bfile ${refgenbis} --pval ${pvalfile} N=$myN --gene-annot ${outname}.genes.annot --gene-model multi=snp-wise --out ${outname} --gene-settings snp-min-maf=0.01 
#awk '{if (f==1) {r[$1]=$5"\t"$6"\t"$8"\t"$9} else if (($1 in r)){print r[$1]"\t"$0}}' f=1 ${outname}.genes.out f=2 $homeDir/biomart_noLRG > ${outname}.genes.out.names
#grep "protein_coding" ${outname}.genes.out.names > ${outname}.genes.out.names.proteins
#awk '{print  $6"\t"$7"\t"$11"\t"$4}' ${outname}.genes.out.names.proteins > ${outname}.prot.tmp
#mv ${outname}.prot.tmp ${outname}.genes.out.names.proteins 

awk '{if (f==1) {r[$1]=$5"\t"$6"\t"$8"\t"$9} else if (($1 in r)){print r[$1]"\t"$0}}' f=1 ${outname}.genes.out f=2 $homeDir/biomart_noLRG > ${outname}.genes.out.names

awk '{print $4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$1}' ${outname}.genes.out.names | perl -e 'print sort { $a <=> $b } <>' - > ${outname}.gene_results;

grep "protein_coding" ${outname}.genes.out.names > ${outname}.genes.out.names.proteins

awk '{print  $6"\t"$7"\t"$11"\t"$4}' ${outname}.genes.out.names.proteins > ${outname}.prot.tmp

mv ${outname}.prot.tmp ${outname}.genes.out.names.proteins 
