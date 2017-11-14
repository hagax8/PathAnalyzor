homeDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
outfile=$1
awk '{if (f==1) {r[$1]=$5"\t"$6"\t"$8"\t"$9} else if (($1 in r)){print r[$1]"\t"$0}}' f=1 ${outfile}.gene_results.genes.out f=2 $homeDir/biomart_noLRG > ${outfile}.gene_results.genes.out.names
awk '{print $4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$1}' ${outfile}.gene_results.genes.out.names | perl -e 'print sort { $a <=> $b } <>' - > ${outfile}.gene_results;
grep "protein_coding" ${outfile}.gene_results.genes.out.names > ${outfile}.gene_results.genes.out.names.proteins
awk '{if($11==""){$11=$5};print $6"\t"$7"\t"$11"\t"$4}' ${outfile}.gene_results.genes.out.names.proteins > ${outfile}.tmp;
mv ${outfile}.tmp ${outfile}.gene_results.genes.out.names.proteins
#do manhattan plot & QQplot with only protein coding genes and annotate best gene in chromosome
sed -i.ba 's/^X/23/g' ${outfile}.gene_results.genes.out.names.proteins
rm ${outfile}.gene_results.genes.out.names.proteins.ba
$homeDir/doManhattan.r ${outfile}.gene_results.genes.out.names.proteins ${outfile}.gene_results 2> ${outfile}.r.log

