#!/bin/bash
#
homeDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
myperl="/users/k1507306/localperl/bin/perl"
#
echo ""
function usage()
{
    echo ""
    echo "-h --help"
    echo ""
    echo "******USAGE:******"
    echo "./pathwayAnalysisPipeline.sh -i sumstats -N samplesize [-o out] [-p {pathwayFile, MSigDB_CP_GO}] [-g {ENSEMBL, NAME, UNIPROT}] [--inf {minnumberofgenesinpathway}] [--sup {maxnumberofgenesinpathway}] [-a {PATHWAY, PROTEIN, ALLGENES}] [-b {PATHWAY, PROTEIN, ALLGENES}]"
    echo ""
    echo "******EXAMPLE:******"
    echo "./pathwayAnalysisPipeline.sh -i in -o out -p MSigDB_CP_GO -g ENSEMBL -l 2 -a PROTEIN"
    echo "./pathwayAnalysisPipeline.sh -v in.genes.raw -d in.genes.out -o out -p MSigDB_CP_GO -g ENSEMBL -l 2 -b PATHWAY"
    echo ""
    echo "******MANDATORY PARAMETERS******"
    echo "only mandatory parameters: -i or -s"
    echo ""
    echo "******PARAMETERS:******"
    echo "-i tab-separated summary statistics, with SNP, P, A1, A2 columns"
    echo "-s tab-separated summary statistics, with SNP, P columns, can be used instead of -i"
    echo "-N sample size of GWAS study"
    echo "-p tab-separated pathway file (first column = ID, other columns = gene id, cf. -g option for gene id type), or generate default pathways with MSigDB_CP_GO"
    echo "-o output"
    echo "-g type of geneID in pathway file, can be ENSEMBL or NAME or UNIPROT, default is ENSEMBL"
    echo "-a genes used for gene analysis, PATHWAY = only genes in pathway, PROTEIN = protein coding (default), ALLGENES = all genes"
    echo "-b genes used for pathway analysis, PATHWAY = only genes in pathway (default), PROTEIN = protein coding, ALLGENES = all genes"
    echo "-v the file provided is a gene annotation file (genes.raw)"
    echo "-d gene result file (.genes.out)"
    echo "-W upstream gene window"
    echo "-w downstream gene window"
    echo "-r change ancestry (EUR = default): EUR, EAS, AMR, SAS, AFR"
    echo "--inf minimum number of genes in pathway (default 10)"
    echo "--sup maximum number of genes in pathway (default 10000)"
    echo ""
    echo "***EXAMPLES:*********"
    echo "-Default MSigDB pathway analysis with pathway genes, gene analysis with protein-coding genes, input file with SNP, P, A1, A2 columns, sample size 10000:"
    echo "$./pathwayAnalysisPipeline.sh -i inputStats -p MSigDB_CP_GO -N 10000 -o ./example_results/outfile"
    echo ""
    echo "-Pathway analysis using user-defined pathways with ENSEMBL ids, pathway analysis with protein-coding genes, gene analysis with ALL genes (+60K genes), input file with SNP, P, A1, A2 columns, sample size 10000":
    echo "$./pathwayAnalysisPipeline.sh -i inputStats -p mypathways -N 10000 -o example_results/outfile -g ENSEMBL -a ALLGENES -b PROTEIN"
    echo ""
    echo "-Pathway analysis using user-defined pathways with gene names, pathway analysis with pathway genes, gene analysis with protein genes, input file with only SNP and P columns, sample size 10000:"
    echo "$./pathwayAnalysisPipeline.sh -s inputStats -p mypathways -N 10000 -o example_results/outfile -g NAME -a PROTEIN -b PATHWAY"
    echo ""
}

referenceSNPpos="${homeDir}/g1000_ref/g1000_EUR_maf0.01.bim"

referenceGENEposPROTEIN="$homeDir/biomart_noLRG_protein_coding"
referenceGENEposALLGENES="$homeDir/biomart_noLRG"
referenceGENEposDRUG="$homeDir/druggable_genome"

referenceNameToENSDict="$homeDir/biomart_dico2"
referenceUniprotToENSDict="$homeDir/biomart_dico3"
referenceENSToNameDict="$homeDir/biomart_dico1"

MSIGDB_GO_PATH="$homeDir/c5.all.v5.2.symbols.gmt"
MSIGDB_CP_PATH="$homeDir/c2.cp.v5.2.symbols.gmt"
PSYPATHWAY_PATH="$homeDir/example_pathways/psy.pathways"
#
#MSIGDB_GO_PATH="$homeDir/c5.all.v5.2.symbols.gmt"
#MSIGDB_CP_PATH="$homeDir/c2.cp.v5.2.symbols.gmt"
#arrays of allowed parameter values
listE=("ENSEMBL" "NAME" "UNIPROT")
listA=("PATHWAY" "PROTEIN" "DRUG" "ALLGENES")
listB=("PATHWAY" "PROTEIN" "DRUG" "ALLGENES")
listL=(2 1000)

function includes {
  local list="$1"
  local item="$2"
  if [[ $list =~ (^|[[:space:]])"$item"($|[[:space:]]) ]] ; then
    result=0
  else
    result=1
  fi
  return $result
}

#default parameters
checkGWAS=false
ensorname="ENSEMBL"
#pathSizeLimit=2
infLimit=10
supLimit=10000
kindOfAnalysisGenes="PROTEIN"
kindOfAnalysisPathways="PATHWAY"
sampleSize=10000
summarystats=""
outfile="$homeDir/example_results/outfile"
kindOfPathway="MSigDB_CP_GO"
downstream=10
upstream=35
ancestry="EUR"
#check mandatory variable
haveGWAS=false
haveSampleSize=false
doAggPathways=false

#check default vars
default_ensorname=true
#default_pathSizeLimit=true
default_infLimit=true
defautl_supLimit=true
default_kindOfAnalysisGenes=true
default_kindOfAnalysisPathways=true
default_outfile=true
default_kindOfPathway=true
default_downstream=true
default_upstream=true
default_referenceSNPpos=true

function useDefault(){

if $default_ensorname || $default_infLimit || $default_supLimit || $default_kindOfAnalysisGenes || $default_kindOfAnalysisPathways || $default_kindOfPathway || $default_outfile || $default_upstream || $default_downstream || $default_referenceSNPpos; then
       echo "****************USING SOME DEFAULT OPTIONS:****************"
fi       
if $default_ensorname; then echo "Default -g option (pathway gene ids): $ensorname"; fi
#if $default_pathSizeLimit; then echo "Default -l option (pathway limit): $pathSizeLimit"; fi
if $default_infLimit; then echo "Default --inf option (min. number of genes in pathway): $infLimit"; fi
if $default_supLimit; then echo "Default --sup option (max. number of genes in pathway): $supLimit"; fi
if $default_kindOfAnalysisGenes; then echo "Default -a option (set of genes for gene analysis): $kindOfAnalysisGenes"; fi
if $default_kindOfAnalysisPathways; then echo "Default -b option (set of genes for pathway analysis): $kindOfAnalysisPathways"; fi
if $default_kindOfPathway; then echo "Default -p option (pathways to use): $kindOfPathway"; fi
if $default_outfile; then echo "Default -o option (output file): $outfile"; fi
if $default_upstream; then echo "Default -W option (upstream window): $upstream"; fi
if $default_downstream; then echo "Default -w option (downstream window): $downstream"; fi
if $default_referenceSNPpos; then echo "Default -r option (ancestry): $ancestry"; fi
echo ""

}


echo "***************YOUR OPTIONS FOR THE PATHWAY ANALYSIS PIPELINE:**********************"
while [ "$1" != "" ]; do
    PARAM=$(echo $1 | awk -F" " '{printf $1}')
    VALUE=$(echo $2 | awk -F" " '{printf $1}')
    case $PARAM in
        -h | --help)
            usage
            exit 
            ;;
        -i)
            summarystats=$VALUE
	    checkGWAS=true
	    haveGWAS=true
	    echo "$PARAM: $VALUE"
            ;;
	-v)
	    doAggPathways=true
	    checkGWAS=false
            haveGWAS=true
	    inputRaw=$VALUE
	    ;;
        -d)
            doAggPathways=true
            checkGWAS=false
            haveGWAS=true
            generesultfile=$VALUE
            ;;
        -s)
            summarystats=$VALUE
            checkGWAS=false
            haveGWAS=true
	    echo "$PARAM: $VALUE"
            ;;
        -N)
            sampleSize=$VALUE
            haveSampleSize=true
	    echo "$PARAM: $VALUE"
	    ;;
        -o)
            outfile=$VALUE
	    default_outfile=false
	    echo "$PARAM: $VALUE"
            ;;
        -W)
            upstream=$VALUE
            default_upstream=false
            echo "$PARAM: $VALUE"
            ;;
        -w)
            downstream=$VALUE
            default_downstream=false
            echo "$PARAM: $VALUE"
            ;;
	-p)
            kindOfPathway=$VALUE
	    default_kindOfPathway=false
	    echo "$PARAM: $VALUE"
            ;;
        -g)
            ensorname=$VALUE
	    default_ensorname=false
	    if [[ "$(includes $listE $ensorname)" -eq 1 ]]; then echo "Problem with -g option: allowed values: ENSEMBL, NAME, UNIPROT"; exit 1; fi 
	    echo "$PARAM: $VALUE"
	    ;;
       --inf)
            infLimit=$VALUE
            default_infLimit=false
            echo "${PARAM}: ${VALUE}"
            ;; 
       --sup)
            supLimit=$VALUE
            default_supLimit=false
            echo "${PARAM}: ${VALUE}"
            ;; 
        -a)
            kindOfAnalysisGenes=$VALUE
	    default_kindOfAnalysisGenes=false
	    echo "$PARAM: $VALUE"
	    if [[ "$(includes $listA $kindOfAnalysisGenes)" -eq 1 ]]; then echo "Problem with -a option: allowed values: PATHWAY, PROTEIN, DRUG, ALLGENES"; exit 1; fi
            ;;
	-r)
	   ancestry=$VALUE
	   referenceSNPpos="${homeDir}/g1000_ref/g1000_${ancestry}_maf0.01.bim"
	   default_referenceSNPpos=false
	   echo "$PARAM: $VALUE"
	   ;;
    	-b)
            kindOfAnalysisPathways=$VALUE
	    default_kindOfAnalysisPathways=false
	    echo "$PARAM: $VALUE"
            if [[ "$(includes $listB $kindOfAnalysisPathways)" -eq 1 ]]; then echo "Problem with -b option: allowed values: PATHWAY, PROTEIN, DRUG, ALLGENES"; exit 1; fi
            ;;	   
        *)
            echo "ERROR: unknown parameter $PARAM with value $VALUE"
            usage
            exit 1
            ;;
    esac
    shift 2 
done
echo "";

if ! $haveGWAS; 
then
	echo "Missing GWAS summary statistics: mandatory -i or -s option"
	usage
	exit 1
fi

if ! $haveSampleSize;
then
	echo "Missing sample size (-N): setting to 10000"
        haveSampleSize=true
	sampleSize=10000
fi

useDefault

echo "**********************************"
echo "ENTERING PATHWAY ANALYSIS PIPELINE"
echo "**********************************"
echo "Pipeline for pathway analysis (a wrapper for MAGMA, a software by de Leeuw et al) by H. A. Gaspar, KCL"
echo ""
echo "*****PREPARING GWAS SUMMARY STATISTICS******"
##filter variants with EUROPEAN 1000G phase 3 v5a, INFO>0.6
##variants identifiers: remove chr identifier, replace _ by :, allow for D/I notation

if $checkGWAS;
then
	${homeDir}/prepareGWAS.py ${summarystats} ${referenceSNPpos} ${outfile}.snps #> ${outfile}.gwas.log 
	else
	if  [[ $doAggPathways = false ]]; then
	cp ${summarystats} ${outfile}.snps
fi
fi
echo ""
echo "**********PREPARING PATHWAYS**********"
if [[ "${kindOfPathway}" = "MSigDB_CP_GO" ]];
then
	thedir=$(dirname "$outfile")
	cat ${MSIGDB_GO_PATH} ${MSIGDB_CP_PATH} > $thedir/MSigDB_CP_GO
	sed -i.ba "s/.http:\/\/www\./\?getlink?http:\/\/www\./g" $thedir/MSigDB_CP_GO
	rm $thedir/MSigDB_CP_GO.ba
	${homeDir}/preparePathways.sh $thedir/MSigDB_CP_GO $thedir/MSigDB_CP_GO ${referenceNameToENSDict} ${referenceGENEposALLGENES} ${infLimit} ${supLimit}
	pathout=$thedir/MSigDB_CP_GO
else 
	pathout=$(dirname "$outfile")/$(basename "$kindOfPathway")
	sed -i.ba "s/ /_/g" $kindOfPathway 
	if [[ ${ensorname} = "NAME" ]];
	then
		$homeDir/preparePathways.sh ${kindOfPathway} ${pathout} ${referenceNameToENSDict} ${referenceGENEposALLGENES} ${infLimit} ${supLimit}
	elif [[ ${ensorname} = "UNIPROT" ]];
        then
                $homeDir/preparePathways.sh ${kindOfPathway} ${pathout} ${referenceUniprotToENSDict} ${referenceGENEposALLGENES} ${infLimit} ${supLimit}
	else
		$homeDir/preparePathways_ENS.sh ${kindOfPathway} ${pathout} ${referenceENSToNameDict} ${referenceGENEposALLGENES} ${infLimit} ${supLimit}
	fi
fi
#
pathname=${pathout}.ensids.grouped.${infLimit}-${supLimit}
pathnameOrig=${pathout}.genenames.grouped.${infLimit}-${supLimit}
refgenpathway=${pathout}_GenesH19

echo "Pathways with ENSEMBL identifiers written to $pathname"
echo "Pathways with NAMES identifiers written to $pathnameOrig"
echo ""

if [[ "${kindOfAnalysisGenes}" = "PATHWAY" ]];
then
	refge=${refgenpathway}
	echo "You chose gene analysis with pathway genes."
elif [[ "${kindOfAnalysisGenes}" = "PROTEIN" ]];
then
	echo "You chose gene analysis with protein-coding genes."
	refge=${referenceGENEposPROTEIN}
elif [[ "${kindOfAnalysisGenes}" = "ALLGENES" ]];
then
	echo "You chose gene analysis with protein-coding and non-coding genes."
	refge=${referenceGENEposALLGENES}
elif [[ "${kindOfAnalysisGenes}" = "DRUG" ]];
then
	echo "You chose gene analysis with druggable genes."
	refge=${referenceGENEposDRUG}
else
	exit 1
fi


if [[ "${kindOfAnalysisPathways}" = "PATHWAY" ]];
then
        refpath=${refgenpathway}
        echo "You chose pathway analysis with pathway genes."
elif [[ "${kindOfAnalysisPathways}" = "PROTEIN" ]];
then    
        echo "You chose pathway analysis with protein-coding genes."
        refpath=${referenceGENEposPROTEIN}
elif [[ "${kindOfAnalysisPathways}" = "ALLGENES" ]];
then    
        echo "You chose pathway analysis with protein-coding and non-coding genes."
        refpath=${referenceGENEposALLGENES}
elif [[ "${kindOfAnalysisPathways}" = "DRUG" ]];
then   
	echo "You chose pathway analysis with druggable genes."
	refpath=${referenceGENEposDRUG}
else
        exit 1
fi
 
echo ""


echo "*********PERFORMING PATHWAY ANALYSIS***************"
#MAGMA pathway analysis with 35kb upstream and only genes in pathway
if  [[ $doAggPathways = true ]]; then
${homeDir}/doMAGMA_onlyPaths.sh $inputRaw $pathname $outfile > ${outfile}.pathwayAnalysis.log
printf "COMP_P\tSELF_P\tNAME\tNGENES\n" > ${outfile}; awk 'NR>4{printf "%s\t%s\t%s\t%s\n", $6,$7,$8,$2}' ${outfile}.sets.out | perl -e 'print sort { $a <=> $b } <>' - >> ${outfile};
echo "${outfile}: PATHWAY SIGNIFICANCE ORDERED BY COMPETITIVE P-VALUE"
echo ""
else
${homeDir}/doMAGMA_windows.sh ${referenceSNPpos} ${refpath} ${outfile}.snps ${pathname} ${outfile}.pathway_results $sampleSize $upstream $downstream > ${outfile}.pathwayAnalysis.log
generesultfile=${outfile}.pathway_results.genes.out 
printf "COMP_P\tSELF_P\tNAME\tNGENES\n" > ${outfile}.pathway_results; awk 'NR>4{printf "%s\t%s\t%s\t%s\n", $6,$7,$8,$2}' ${outfile}.pathway_results.sets.out | perl -e 'print sort { $a <=> $b } <>' - >> ${outfile}.pathway_results;
echo "${outfile}.pathway_results: PATHWAY SIGNIFICANCE ORDERED BY COMPETITIVE P-VALUE"
echo ""
fi


if [[ $kindOfAnalysisGenes = $kindOfAnalysisPathways ]]; then
echo "We keep the pathway analysis results for the genes since the gene ensembles are the same..."
echo ""
else
if  [[ $doAggPathways = false ]]; then
echo "*********PERFORMING GENE ANALYSIS (THIS COULD TAKE A WHILE)***********"
${homeDir}/doMAGMA_windows_onlygenes.sh ${referenceSNPpos} ${refge} ${outfile}.snps ${outfile}.gene_results $sampleSize $upstream $downstream > ${outfile}.geneAnalysis.log
generesultfile=${outfile}.gene_results.genes.out
echo "${outfile}.gene_results.genes.out.names: GENE SIGNIFICANCE WITH GENE NAMES"
echo ""
fi
fi


echo "***********PRODUCING MANHATTAN AND QQPLOTS AND HTML VIS FOR GENES AND PATHWAYS*************"
if  [[ $doAggPathways = false ]]; then
${homeDir}/plotGenes.sh $generesultfile ${outfile}.gene_results ${ensorname} 
${homeDir}/plotPathways.sh ${outfile}.pathway_results.sets.out ${outfile} ${ensorname} 
else
${homeDir}/plotPathways.sh ${outfile}.sets.out ${outfile} ${ensorname} 
fi

if ! $checkGWAS; then if ! $doAggPathways; then rm ${outfile}.snps; fi; fi


if  [[ $doAggPathways = false ]]; then
echo ""
echo "************WRITING RESULTS INTO EXCEL SHEET***********"
echo "${outfile}_GENES_AND_PATHWAYS.xls: EXCEL FILE, GENES AND PATHWAYS ASSOCIATIONS WITH REFERENCE PATHWAYS"
PERL_DL_NONLAZY=1 $myperl ${homeDir}/csvToExcel.pl 4 ${outfile}_GENES_AND_PATHWAYS ${outfile}.gene_results GENE_results ${outfile}.pathway_results PATHWAY_results ${pathnameOrig} GENE_SET_NAMES ${pathname} GENE_SET_ENS
fi

echo ""
echo "##########OUTPUT FILES#############"
echo "${outfile}.pathway_results: PATHWAY SIGNIFICANCE ORDERED BY COMPETITIVE P-VALUE"
echo "${outfile}.gene_results.pdf: GENE RESULTS FIGURES"
echo "${outfile}.pathway_results.pdf: PATHWAY RESULTS FIGURES"
echo "${outfile}_GENES_AND_PATHWAYS.xls: EXCEL FILE, GENES AND PATHWAYS ASSOCIATIONS WITH REFERENCE PATHWAYS"
echo ""
echo "#########END########"
echo ""
echo ""
cp $pathname ${outfile}_pathwayids.txt

rm ${pathout}.genenames.grouped ${pathout}.genenames ${pathout}.ensids.grouped ${pathout}.ensids ${pathout}.ens.genes 
	rm ${pathout}_GenesH19
	rm ${pathout}.genenames.grouped.${infLimit}-${supLimit}
	rm ${pathout}.ensids.grouped.${infLimit}-${supLimit}
