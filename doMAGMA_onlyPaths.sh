#!/usr/bin/env bash
#inputraw is the input raw 
#genesets is the gene sets file
#outname is the output name
homeDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "$(uname)" == "Darwin" ]; then
	magmaDir=$homeDir/magma_mac
else
	magmaDir=$homeDir/magma
fi

inputraw=$1
genesets=$2
outname=$3
#example: 
#./doMAGMA.sh g1000.bim genloc pvalfile genesets outname 16731

$magmaDir --gene-results $inputraw --set-annot ${genesets} self-contained --out ${outname} 
#awk '{if (f==1) {r[$1]=$5"\t"$6"\t"$8"\t"$9} else if (($1 in r)){print r[$1]"\t"$0}}' f=1 ${outname}.genes.out f=2 biomart_noLRG > ${outname}.genes.out.names
