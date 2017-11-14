homeDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
${homeDir}/onlySelectedEnrichment.sh $1 > $1.seldrugclass  
