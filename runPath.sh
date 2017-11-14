in=$1 
out=$2
N=$3
homeDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
myperl="/users/k1507306/localperl/bin/perl"

#run gene associations
$homeDir/doOnlyGenes.sh $in $out $N 

$homeDir/plotGenes.sh ${out}.gene_results.genes.out ${out} ENSEMBL
 
#run msigdb and psy pathways
$homeDir/runPathways.sh ${out}.gene_results $N ${out}

PERL_DL_NONLAZY=1 $myperl ${homeDir}/csvToExcel.pl 7 ${out}_GENES_AND_PATHWAYS ${out}.gene_results GENE_results ${out}_geneFamilies GeneFamilies ${out}_targetValidation OpenTargetsDiseases ${out}_msigdbAndPsy MSigdbAndPsy ${out}_allPathways AllPathways ${out}_drugsAll DrugsAll ${out}_drugsBioact DrugsWithBioact
