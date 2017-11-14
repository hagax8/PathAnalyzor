homeDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
${homeDir}/doDrugEnrichment.sh $1 > $1.drugclass_with4  
