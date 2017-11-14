in=$1
N=$2
out=$3
homeDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
allPathways=${homeDir}/example_pathways/allpaths
msigdbAndPsy=${homeDir}/example_pathways/MSigDB_PSY
targetValidation=${homeDir}/example_pathways/targetval_finalpath
geneFamilies=${homeDir}/example_pathways/gene_families_withlinks
drugsAll=${homeDir}/example_pathways/all.connections_ATC_sup_withlinks
drugsBioact=${homeDir}/example_pathways/all.connections_ATC_withlinks

#run msigdb and psy pathways
${homeDir}/pathwayAnalysisPipeline.sh -v ${in}.genes.raw -d ${in}.genes.out -o ${out}_msigdbAndPsy -p ${msigdbAndPsy} -g ENSEMBL --inf 5 --sup 10000 -N $N -a PROTEIN -b PROTEIN

#run target validation pathways 
${homeDir}/pathwayAnalysisPipeline.sh -v ${in}.genes.raw -d ${in}.genes.out -o ${out}_targetValidation -p ${targetValidation} -g ENSEMBL --inf 5 --sup 10000 -N $N -a PROTEIN -b PROTEIN

#run gene families
${homeDir}/pathwayAnalysisPipeline.sh -v ${in}.genes.raw -d ${in}.genes.out -o ${out}_geneFamilies -p ${geneFamilies} -g NAME --inf 1 --sup 10000 -N $N -a PROTEIN -b PROTEIN

#run all
${homeDir}/pathwayAnalysisPipeline.sh -v ${in}.genes.raw -d ${in}.genes.out -o ${out}_allPathways -p ${allPathways} -g ENSEMBL --inf 5 --sup 10000 -N $N -a PROTEIN -b PROTEIN

#run drugs: all interactions
${homeDir}/pathwayAnalysisPipeline.sh -v ${in}.genes.raw -d ${in}.genes.out -o ${out}_drugsAll -p $drugsAll -g NAME --inf 1 --sup 10000 -N $N -a PROTEIN -b PROTEIN

#run drugs: only bioactivities 
${homeDir}/pathwayAnalysisPipeline.sh -v ${in}.genes.raw -d ${in}.genes.out -o ${out}_drugsBioact -p $drugsBioact -g NAME --inf 1 --sup 10000 -N $N -a PROTEIN -b PROTEIN

