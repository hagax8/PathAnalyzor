homeDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dirpath=${homeDir}/example_pathways
lcount=$(wc -l ${dirpath}/mydrugsets/alldrugs_ATC_classes | gawk '{prinf $1}')
echo $lcount

for i in N06AA N06AB N06AF N06AG N06AX N06BA N06BC N06BX N06CA N06CB N06DA N06DX; do id=${i}; name=$(gawk -F"\t" -v myvar=${i} '{if($1==myvar){printf "%s",$2}}' ${dirpath}/mydrugsets/alldrugs_ATC_classes); mycount=$(wc -l ${dirpath}/mydrugsets/drugsClass_${id} | awk '{printf $1}'); if [[ $mycount -gt 10 ]]; then printf "%s\t%s\t%s" "$id" "$name" "$mycount"; ${mydir}/doEnrichmentCurve_new.sh $1 $1.DRUGS_AUC_${id} ${dirpath}/mydrugsets/drugsClass_${id} | awk -F" " '{if($1=="Normalized"){getline;printf "\t"$2}if($1=="P-value"){getline;printf "\t"$2}if($1=="Ustat"){getline;printf "\t"$2}}'; awk -F"\t" 'BEGIN{mycount=0}{mycount+=$3}END{printf "\t"mycount"\n"}' $1.DRUGS_AUC_${id}_ordered; fi; done

