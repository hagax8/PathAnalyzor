infile=$1
outfile=$2
#homeDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
homeDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
referenceGENEposPROTEIN="$homeDir/biomart_noLRG_protein_coding"
refge=${referenceGENEposPROTEIN}
referenceSNPpos="${homeDir}/g1000_ref/g1000_EUR_maf0.01.bim"
sampleSize=$3
upstream=35
downstream=10
${homeDir}/doMAGMA_windows_onlygenes.sh ${referenceSNPpos} ${refge} ${infile} ${outfile}.gene_results $sampleSize $upstream $downstream > ${outfile}.geneAnalysis.log

