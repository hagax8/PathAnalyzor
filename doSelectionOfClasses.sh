nameOfFile=$1
nameOfOutput=${1}.sel
sed -i -e 's/^[[:blank:]]*$//' $nameOfFile
printf "COMP_P\tCODE\tNAME\tN\tAUC\tN_FOUND\n" > ${nameOfOutput};
gawk -F"\t" '{if(NF>4&&$NF>=10){printf $5"\t"$1"\t"$2"\t"$3"\t"$4"\t"$6"\n";}}' $nameOfFile | perl -e 'print sort { $a <=> $b } <>' | gawk -F"\t" '{threeletters=substr($2,0,3);completerecord=threeletters"\t"$1"\t"$4"\t"$5"\t"$6;if(!(completerecord in refname)||(length(refname[completerecord])<length($2))){refname[completerecord]=$2;printrecord[completerecord]=$0;}}END{for(i in printrecord){print printrecord[i]}}' | perl -e 'print sort { $a <=> $b } <>' >> ${nameOfOutput};
./insertQ.r ${nameOfOutput}


