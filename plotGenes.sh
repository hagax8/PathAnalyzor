###usage= generesults output ENSEMBLE 
homeDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
generesults=$1
output=$2
nameOrEnsembl=$3
echo ""
echo "***********PRODUCING MANHATTAN AND QQPLOTS FOR GENES*************"
if [[ $nameOrEnsembl = "ENSEMBL" ]]; then
	awk '{if (f==1) {r[$1]=$5"\t"$6"\t"$8"\t"$9} else if (($1 in r)){print r[$1]"\t"$0}}' f=1 ${generesults} f=2 ${homeDir}/biomart_noLRG > ${generesults}.names;
elif [[ $nameOrEnsembl = "NAME" ]]; then
	awk '{if (f==1) {r[$1]=$5"\t"$6"\t"$8"\t"$9} else if (($7 in r)){print r[$1]"\t"$0}}' f=1 ${generesults} f=2 ${homeDir}/biomart_noLRG > ${generesults}.names;
fi

awk '{print $4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$1}' ${generesults}.names | perl -e 'print sort { $a <=> $b } <>' - > ${output}.gene_results;
grep "protein_coding" ${generesults}.names > ${generesults}.names.proteins
awk '{print  $6"\t"$7"\t"$11"\t"$4}' ${generesults}.names.proteins > ${output}.tmp;
mv ${output}.tmp ${generesults}.names.proteins 
#do manhattan plot & QQplot with only protein coding genes and annotate best gene in chromosome
sed -i.ba 's/^X/23/g' ${generesults}.names.proteins
rm ${generesults}.names.proteins.ba
${homeDir}/doManhattan.r ${generesults}.names.proteins ${output}.gene_results 2> ${output}.r.log
echo "${output}.gene_results.pdf: GENE RESULTS FIGURES"

awk -F"\t" 'BEGIN{print"P\tENSEMBL\tCHROMOSOME\tBEGIN\tEND\tSTRAND\tPROTEIN_CODING\tNAME\tNSPNS"}{print}' ${output}.gene_results > ${output}.gene_results.tmp; mv ${output}.gene_results.tmp ${output}.gene_results;

$homeDir/insertQ_forGenes.r ${output}.gene_results

rm ${generesults}.names.proteins
rm ${generesults}.names

echo ""

