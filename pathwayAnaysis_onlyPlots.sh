###usage= generesults pathwayresults output ENSEMBLE 
homeDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
generesults=$1
pathwayresults1=$2
output=$3
nameOrEnsembl=$4
pathwayresults=$3

printf "COMP_P\tSELF_P\tNAME\tNGENES\n" > ${pathwayresults}; awk 'NR>4{printf "%s\t%s\t%s\t%s\n", $6,$7,$8,$2}' ${pathwayresults1} | perl -e 'print sort { $a <=> $b } <>' - >> ${pathwayresults};

${homeDir}/insertQ.r ${pathwayresults};
mv ${pathwayresults}p ${pathwayresults};
echo "***********PRODUCING MANHATTAN AND QQPLOTS FOR GENES*************"
if [[ nameOrEnsembl == "ENSEMBLE" ]]; then
	awk '{if (f==1) {r[$1]=$5"\t"$6"\t"$8"\t"$9} else if (($1 in r)){print r[$1]"\t"$0}}' f=1 ${generesults} f=2 biomart_noLRG > ${generesults}.names;
elif [[ nameOrEnsembl == "NAME" ]]; then
	awk '{if (f==1) {r[$1]=$5"\t"$6"\t"$8"\t"$9} else if (($7 in r)){print r[$1]"\t"$0}}' f=1 ${generesults} f=2 biomart_noLRG > ${generesults}.names;
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

rm ${generesults}.names.proteins
rm ${generesults}.names

echo ""
echo "************PRODUCING QQPLOTS FOR PATHWAYS***********"
${homeDir}/qqplot_pathways.r ${pathwayresults} ${pathwayresults} 2>> ${output}.r.log
cp ${homeDir}/htmltemplate.html ${output}.table.html
cp ${homeDir}/htmltemplate.html ${output}.bubble.html
${homeDir}/barPlotGvis.r ${pathwayresults} ${output}.table.html 2>> ${output}.r.log
${homeDir}/bubblePlotGvis.r ${pathwayresults} ${output}.bubble.html 2>> ${output}.r.log

