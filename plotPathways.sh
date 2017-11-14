###usage= pathwayresults output ENSEMBLE 
homeDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pathwayresults1=$1
output=$2
nameOrEnsembl=$3
pathwayresults=$2

printf "COMP_P\tSELF_P\tNAME\tNGENES\n" > ${pathwayresults}; awk 'NR>4{printf "%s\t%s\t%s\t%s\n", $6,$7,$8,$2}' ${pathwayresults1} | perl -e 'print sort { $a <=> $b } <>' - >> ${pathwayresults};

echo ""
echo "************PRODUCING QQPLOTS FOR PATHWAYS***********"
${homeDir}/qqplot_pathways.r ${pathwayresults} ${pathwayresults} 2>> ${output}.r.log

${homeDir}/insertQ.r ${pathwayresults};

awk -F"\t" 'NR==1{print "COMP_P\tSELF_P\tNAME\tLINK\tNGENES\tq_valueBH\tq_valueBY\tp_valueBF"}NR>1{split($3,a,";");for(i in a){split(a[i],b,"\?getlink\\?"); printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",$1,$2,b[1],b[2],$4,$5,$6,$7;}}' ${pathwayresults}p > ${pathwayresults};

echo ""
echo "************PRODUCING HTML VIS FOR PATHWAYS***********"
cp ${homeDir}/htmltemplate.html ${output}.table.html
cp ${homeDir}/htmltemplate.html ${output}.bubble.html
${homeDir}/barPlotGvis.r ${pathwayresults} ${output}.table.html 2>> ${output}.r.log
${homeDir}/bubblePlotGvis.r ${pathwayresults} ${output}.bubble.html 2>> ${output}.r.log

