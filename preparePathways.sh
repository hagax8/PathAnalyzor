#!/bin/bash
#dictionary can be obtained with biomart file:
#gawk -F"\t" '{if($6!=""){print $6"\t"$1}}' biomart_uncollapsed_noLRG > biomart_dico
#~/Documents/scriptlib/getInteractionsInHash.pl biomart_dico > biomart_dico2
pathways=$1
out=$2
NameToENSDict=$3
genePosRef=$4
homeDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
liminf=$5
limsup=$6
$homeDir/getInteractionsInHashWithNewDictionaryAndGroup.pl $pathways $NameToENSDict $out

if [ "$#" -ne 6 ]; then
   liminf=2
   limsup=20000
fi

#awk -F"\t" '{if (f==1) { if(NF>2){r[$1]} } else if (( $1 in r)) {print}}' f=1 ${out}.ensids.grouped f=2 ${out}.ensids.grouped > ${out}.ensids.grouped.atleast2

#awk -F"\t" '{if (f==1) { if(NF>2){r[$1]} } else if (( $1 in r)) {print}}' f=1 ${out}.ensids.grouped f=2 ${out}.genenames.grouped > ${out}.genenames.grouped.atleast2

#sed -i.ba 's|["'\'']||g' ${out}.ensids.grouped
#rm ${out}.ensids.grouped.ba
#sed -i.ba 's|["'\'']||g' ${out}.genenames.grouped
#rm ${out}.genenames.grouped.ba

cut -f 2- ${out}.ensids.grouped | awk -F"\t" '{for(i=1;i<=NF;i++){print $i}}' | sort | uniq > ${out}.ens.genes

awk -F"\t" '{if (f==1) { r[$0] } else if ( ($1 in r)) { print $0 } } ' f=1 ${out}.ens.genes f=2 ${genePosRef} > ${out}_GenesH19

#keep only pathways with a number of genes between 10 and 1000
awk -F"\t" -v myinf=$liminf -v mysup=$limsup '{if (f==1) { if(NF<=(mysup+1)&&NF>=(myinf+1)){r[$1]} } else if (( $1 in r)) {print}}' f=1 ${out}.ensids.grouped f=2 ${out}.ensids.grouped > ${out}.ensids.grouped.${liminf}-${limsup}

awk -F"\t" -v myinf=$liminf -v mysup=$limsup '{if (f==1) {if(NF<=(mysup+1)&&NF>=(myinf+1)){r[$1]} } else if (( $1 in r)) {print}}' f=1 ${out}.ensids.grouped f=2 ${out}.genenames.grouped > ${out}.genenames.grouped.${liminf}-${limsup}
