homeDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
python ${homeDir}/prepareGWAS.py $1 ${homeDir}/g1000_ref/g1000_EUR_maf0.01.bim $2 
