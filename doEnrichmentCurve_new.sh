#DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
homeDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
tail -n +5 $1 | ${homeDir}/orderByPvalue_new.sh - | awk '{print $1"\t"$5}' - > $2_ordered  
#| sed 's/;/\n/g' | awk -F"\t| " '{if(NF<2){$2=$1;$1=p}}{p=$1;if($2!=""){printf "%s\t%s\n",$1,$2}}' -  > $2_ordered  
#awk -F" " '{if (f==1) { r[$0] } else if (($2 in r)) { print 1 } else if (!($2 in r)) {print 0}} ' f=1 $3 f=2 $2_ordered  > $2_01
awk -F";|\t" '{if (f==1) { r[$0] } else {output=0;for(i=1;i<=NF;i++){if ($i in r) {output=1}}print output;}}' f=1 $3 f=2 $2_ordered  > $2_01
paste $2_ordered $2_01 > $2_pasted;
cp $2_pasted $2_ordered;
for i in `seq 1 100`;
	do
		shuf $2_01 > $2_shuff
		paste $2_pasted $2_shuff > $2_pasted2
		mv $2_pasted2 $2_pasted
	done



rm $2_01 $2_shuff

${homeDir}/doEnrichment.r $2_pasted $2_img \#\ Compounds \%\ Retrieved\ Drugs
rm $2_pasted
#rm $2_ordered
