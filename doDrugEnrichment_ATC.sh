homeDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

dirpath=${homeDir}/example_pathways
#lcount=$(wc -l ${dirpath}/mydrugsets/alldrugs_ATC_classes | gawk '{prinf $1}')
#echo $lcount

#for i in `seq 1 360`; do id=$(awk -F"\t" -v myvar=${i} 'NR==myvar{printf $1}' ${dirpath}/mydrugsets/alldrugs_ATC_classes); name=$(gawk -F"\t" -v myvar=${i} 'NR==myvar{printf "%s",$2}' ${dirpath}/mydrugsets/alldrugs_ATC_classes); mycount=$(wc -l ${dirpath}/mydrugsets/drugsClass_${id} | awk '{printf $1}'); if [[ $mycount -gt 10 ]]; then printf "%s\t%s\t%s" "$id" "$name" "$mycount"; ${homeDir}/doEnrichmentCurve_new.sh $1 $1.DRUGS_AUC_${id} ${dirpath}/mydrugsets/drugsClass_${id} | awk -F" " '{if($1=="Normalized"){getline;printf "\t"$2}if($1=="P-value"){getline;printf "\t"$2}if($1=="Ustat"){getline;printf "\t"$2}}'; awk -F"\t" 'BEGIN{mycount=0}{mycount+=$3}END{printf "\t"mycount"\n"}' $1.DRUGS_AUC_${id}_ordered; fi; done

for i in `seq 1 1204`; do id=$(awk -F"\t" -v myvar=${i} 'NR==myvar{printf $1}' ${dirpath}/mydrugsets/alldrugs_ATC_classes_with4 ); name=$(gawk -F"\t" -v myvar=${i} 'NR==myvar{printf "%s",$2}' ${dirpath}/mydrugsets/alldrugs_ATC_classes_with4 ); mycount=$(wc -l ${dirpath}/mydrugsets/drugsClass_${id} | awk '{printf $1}'); if [[ $mycount -gt 9 ]]; then printf "%s\t%s\t%s" "$id" "$name" "$mycount"; ${homeDir}/doEnrichmentCurve_new_ATC.sh $1 $1.DRUGS_AUC_${id} ${id} | awk -F" " '{if($1=="Normalized"){getline;printf "\t"$2}if($1=="P-value"){getline;printf "\t"$2}if($1=="Ustat"){getline;printf "\t"$2}}'; awk -F"\t" 'BEGIN{mycount=0}{mycount+=$3}END{printf "\t"mycount"\n"}' $1.DRUGS_AUC_${id}_ordered; fi; rm $1.DRUGS_AUC_${id}_ordered; done
