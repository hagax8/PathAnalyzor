#!/bin/bash
#
homeDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#

function usage()
{
    echo ""
    echo "-h --help"
    echo ""
    echo "******USAGE:******"
    echo "./pathwayAnalysisPipeline.sh -i sumstats -N samplesize [-o out] [-p {pathwayFile, MSigDB_CP_GO}] [-e {ENSEMBLE, NAME, UNIPROT}] [-l {2,1000}] [-a {PATHWAY, PROTEIN, ALLGENES}] [-b {PATHWAY, PROTEIN, ALLGENES}]"
    echo ""
    echo "******EXAMPLE:******"
    echo "./pathwayAnalysisPipeline.sh -i in -o out -p MSigDB_CP_GO -e ENSEMBLE -l 1000 -a PROTEIN"
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
    echo "-g type of geneID in pathway file, can be ENSEMBLE or NAME or UNIPROT, default is ENSEMBLE"
    echo "-l pathway size limit, default is 2 (size>=2), if set to 1000, then 10<=size<=1000"
    echo "-a genes used for gene analysis, PATHWAY = only genes in pathway, PROTEIN = protein coding (default), ALLGENES = all genes"
    echo "-b genes used for pathway analysis, PATHWAY = only genes in pathway (default), PROTEIN = protein coding, ALLGENES = all genes"
    echo "-v the file provided in -i is a gene annotation file"
    echo "-W upstream gene window"
    echo "-w downstream gene window"
    echo "-r change ancestry (EUR = default): EUR, EAS, AMR, SAS, AFR"
    echo ""
    echo "***EXAMPLES:*********"
    echo "-Default MSigDB pathway analysis with pathway genes, gene analysis with protein-coding genes, input file with SNP, P, A1, A2 columns, sample size 10000:"
    echo "$./pathwayAnalysisPipeline.sh -i inputStats -p MSigDB_CP_GO -N 10000 -o ./example_results/outfile"
    echo ""
    echo "-Pathway analysis using user-defined pathways with ENSEMBLE ids, pathway analysis with protein-coding genes, gene analysis with ALL genes (+60K genes), input file with SNP, P, A1, A2 columns, sample size 10000":
    echo "$./pathwayAnalysisPipeline.sh -i inputStats -p mypathways -N 10000 -o example_results/outfile -g ENSEMBLE -a ALLGENES -b PROTEIN"
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

MSIGDB_GO_PATH="$homeDir/c5.all.v5.1.symbols.gmt"
MSIGDB_CP_PATH="$homeDir/c2.cp.v5.1.symbols.gmt"
#
#MSIGDB_GO_PATH="$homeDir/c5.all.v5.2.symbols.gmt"
#MSIGDB_CP_PATH="$homeDir/c2.cp.v5.2.symbols.gmt"
#arrays of allowed parameter values
listE=("ENSEMBLE" "NAME" "UNIPROT")
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
ensorname="ENSEMBLE"
pathSizeLimit=2
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
default_pathSizeLimit=true
default_kindOfAnalysisGenes=true
default_kindOfAnalysisPathways=true
default_outfile=true
default_kindOfPathway=true
default_downstream=true
default_upstream=true
default_referenceSNPpos=true

function useDefault(){

if $default_ensorname || $default_pathSizeLimit || $default_kindOfAnalysisGenes || $default_kindOfAnalysisPathways || $default_kindOfPathway || $default_outfile || $default_upstream || $default_downstream || $default_referenceSNPpos; then
       echo "****************USING SOME DEFAULT OPTIONS:****************"
fi       
if $default_ensorname; then echo "Default -g option (pathway gene ids): $ensorname"; fi
if $default_pathSizeLimit; then echo "Default -l option (pathway limit): $pathSizeLimit"; fi
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
    #PARAM=`echo $1 | awk '{print $1}'`
    #VALUE=`echo $1 | awk '{print $2}'`
    #PARAM=`echo $1 | awk '{print $1}'`
    #VALUE=`echo $2 | awk '{print $1}'`
    PARAM=$(echo $1 | awk -F" " '{printf $1}')
    #echo $PARAM
    VALUE=$(echo $2 | awk -F" " '{printf $1}')
    #echo $VALUE
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
	    if [[ "$(includes $listE $ensorname)" -eq 1 ]]; then echo "Problem with -g option: allowed values: ENSEMBLE, NAME, UNIPROT"; exit 1; fi 
	    echo "$PARAM: $VALUE"
	    ;;
        -l)
	    pathSizeLimit=$VALUE
	    default_pathSizeLimit=false
	    echo "${PARAM}: ${VALUE}"
	    if [[ "$(includes $listL $pathSizeLimit)" -eq 1 ]]; then echo "Problem with -l option: allowed values: 2, 1000"; exit 1; fi 
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
	#usage
        #exit 1
fi

useDefault
#

echo "**********************************"
echo "ENTERING PATHWAY ANALYSIS PIPELINE"
echo "**********************************"
#
echo "Written by Dr. H. A. Gaspar, King's College London"
echo ""
echo "*****PREPARING GWAS SUMMARY STATISTICS******"
##filter variants with EUROPEAN 1000G phase 3 v5a, INFO>0.6
##variants identifiers: remove chr identifier, replace _ by :, allow for D/I notation

if $checkGWAS;
then
	$homeDir/prepareGWAS.py ${summarystats} ${referenceSNPpos} ${outfile}.snps #> ${outfile}.gwas.log 
else
	cp ${summarystats} ${outfile}.snps
fi
echo ""
echo "**********PREPARING PATHWAYS**********"
if [[ "${kindOfPathway}" = "MSigDB_CP_GO" ]];
then
	thedir=$(dirname "$outfile")
	cat ${MSIGDB_GO_PATH} ${MSIGDB_CP_PATH} > $thedir/MSigDB_CP_GO
	sed -i.ba "s/.http:\/\/www\./\?http:\/\/www\./g" $thedir/MSigDB_CP_GO
	rm $thedir/MSigDB_CP_GO.ba
	$homeDir/preparePathways.sh $thedir/MSigDB_CP_GO $thedir/MSigDB_CP_GO ${referenceNameToENSDict} ${referenceGENEposALLGENES}
	pathout=$thedir/MSigDB_CP_GO
else 
	pathout=$(dirname "$outfile")/$(basename "$kindOfPathway")
	sed -i.ba "s/ /_/g" $kindOfPathway 
	if [[ ${ensorname} = "NAME" ]];
	then
		$homeDir/preparePathways.sh ${kindOfPathway} ${pathout} ${referenceNameToENSDict} ${referenceGENEposALLGENES}
	elif [[ ${ensorname} = "UNIPROT" ]];
        then
                $homeDir/preparePathways.sh ${kindOfPathway} ${pathout} ${referenceUniprotToENSDict} ${referenceGENEposALLGENES}
	else
		$homeDir/preparePathways_ENS.sh ${kindOfPathway} ${pathout} ${referenceENSToNameDict} ${referenceGENEposALLGENES}
	fi
fi
#
        if [[ ${pathSizeLimit} -eq 1000 ]];
                then
                        pathname=${pathout}.ensids.grouped.10-1000
                        pathnameOrig=${pathout}.genenames.grouped.10-1000
                else
                        pathname=${pathout}.ensids.grouped.atleast2
                        pathnameOrig=${pathout}.genenames.grouped.atleast2
                fi
        refgenpathway=${pathout}_GenesH19

echo "Pathways with ENSEMBLE identifiers written to $pathname"
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
$homeDir/doMAGMA_windows.sh ${referenceSNPpos} ${refpath} ${outfile}.snps ${pathname} ${outfile}.pathway_results $sampleSize $upstream $downstream > ${outfile}.pathwayAnalysis.log
printf "COMP_P\tSELF_P\tNAME\tNGENES\n" > ${outfile}.pathway_results; awk 'NR>4{printf "%s\t%s\t%s\t%s\n", $6,$7,$8,$2}' ${outfile}.pathway_results.sets.out | perl -e 'print sort { $a <=> $b } <>' - >> ${outfile}.pathway_results;
echo "${outfile}.pathway_results: PATHWAY SIGNIFICANCE ORDERED BY COMPETITIVE P-VALUE"
echo ""
if [[ $kindOfAnalysisGenes = $kindOfAnalysisPathways ]]; then
echo "We keep the pathway analysis results for the genes since the gene ensembles are the same..."
cp ${outfile}.pathway_results.genes.out ${outfile}.gene_results.genes.out
echo ""
else

echo "*********PERFORMING GENE ANALYSIS (THIS COULD TAKE A WHILE)***********"
#MAGMA gene analysis with 35kb upstream with all genes, coding or not
$homeDir/doMAGMA_windows_onlygenes.sh ${referenceSNPpos} ${refge} ${outfile}.snps ${outfile}.gene_results $sampleSize $upstream $downstream > ${outfile}.geneAnalysis.log
#
#$homeDir/doMAGMA_windows.sh ${referenceSNPpos} ${refge} ${outfile}.snps ${kindOfPathway}.ensids.grouped.10-1000 ${outfile}.gene_results $sampleSize 35 > ${outfile}.geneAnalysis.log
#printf "COMP_P\tSELF_P\tNAME\tNGENES\n" > ${outfile}.pathway_allgenes_results; awk 'NR>4{printf "%s\t%s\t%s\t%s\n", $4,$3,$5,$2}' ${outfile}.gene_results.sets.out | perl -e 'print sort { $a <=> $b } <>' - >> ${outfile}.pathway_allgenes_results;
echo "${outfile}.gene_results.genes.out.names: GENE SIGNIFICANCE WITH GENE NAMES"
echo ""
fi

echo "***********PRODUCING MANHATTAN AND QQPLOTS FOR GENES*************"
awk '{if (f==1) {r[$1]=$5"\t"$6"\t"$8"\t"$9} else if (($1 in r)){print r[$1]"\t"$0}}' f=1 ${outfile}.gene_results.genes.out f=2 biomart_noLRG > ${outfile}.gene_results.genes.out.names

awk '{print $4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$1}' ${outfile}.gene_results.genes.out.names | perl -e 'print sort { $a <=> $b } <>' - > ${outfile}.gene_results;
grep "protein_coding" ${outfile}.gene_results.genes.out.names > ${outfile}.gene_results.genes.out.names.proteins
awk '{print  $6"\t"$7"\t"$11"\t"$4}' ${outfile}.gene_results.genes.out.names.proteins > ${outfile}.tmp; 
mv ${outfile}.tmp ${outfile}.gene_results.genes.out.names.proteins
#do manhattan plot & QQplot with only protein coding genes and annotate best gene in chromosome
sed -i.ba 's/^X/23/g' ${outfile}.gene_results.genes.out.names.proteins
rm ${outfile}.gene_results.genes.out.names.proteins.ba
$homeDir/doManhattan.r ${outfile}.gene_results.genes.out.names.proteins ${outfile}.gene_results 2> ${outfile}.r.log
echo "${outfile}.gene_results.pdf: GENE RESULTS FIGURES"

echo ""
echo "************PRODUCING QQPLOTS FOR PATHWAYS***********"
$homeDir/qqplot_pathways.r ${outfile}.pathway_results ${outfile}.pathway_results 2>> ${outfile}.r.log
cp $homeDir/htmltemplate.html ${outfile}.table.html
cp $homeDir/htmltemplate.html ${outfile}.bubble.html
$homeDir/barPlotGvis.r ${outfile}.pathway_results ${outfile}.table.html 2>> ${outfile}.r.log
$homeDir/bubblePlotGvis.r ${outfile}.pathway_results ${outfile}.bubble.html 2>> ${outfile}.r.log
echo "${outfile}.pathway_results.pdf: PATHWAY RESULTS FIGURES"
if ! $checkGWAS; then rm ${outfile}.snps; fi
#comment this if you want to keep all files
#rm ${outfile}.r.log
#rm ${outfile}.pathwayAnalysis.log 
rm ${outfile}.pathway_results.genes.annot ${outfile}.pathway_results.genes.out ${outfile}.pathway_results.genes.out.names ${outfile}.pathway_results.genes.raw ${outfile}.gene_results.genes.annot ${outfile}.gene_results.genes.raw

echo ""

echo P$'\t'ENSEMBLE$'\t'CHR$'\t'BEGIN$'\t'END$'\t'STRAND$'\t'TYPE$'\t'GENE NAME$'\t'NSNPS | cat - ${outfile}.gene_results > ${outfile}.temp; 
mv ${outfile}.temp ${outfile}.gene_results
echo NAME$'\t'GENE | cat - ${pathname} > ${outfile}.temp; mv ${outfile}.temp ${pathname}  

echo NAME$'\t'GENE | cat - ${pathnameOrig} > ${outfile}.temp; mv ${outfile}.temp ${pathnameOrig}



echo "************WRITING RESULTS INTO EXCEL SHEET***********"
echo "${outfile}_GENES_AND_PATHWAYS.xls: EXCEL FILE, GENES AND PATHWAYS ASSOCIATIONS WITH REFERENCE PATHWAYS"
PERL_DL_NONLAZY=1 perl ./csvToExcel.pl 4 ${outfile}_GENES_AND_PATHWAYS ${outfile}.gene_results GENE_results ${outfile}.pathway_results PATHWAY_results ${pathnameOrig} GENE_SET_NAMES ${pathname} GENE_SET_ENS

sed -i.ba '1d' ${pathname}
sed -i.ba '1d' ${pathnameOrig}

rm ${pathname}.ba
rm ${pathnameOrig}.ba

echo ""
echo "##########OUTPUT FILES#############"
#echo "${outfile}.gene_results.genes.out.names: GENE SIGNIFICANCE WITH GENE NAMES"
#echo "${outfile}.gene_results.genes.out.names.proteins: GENE SIGNIFICANCE WITH GENE NAMES, ONLY PROTEIN-CODING GENES"
echo "${outfile}.pathway_results: PATHWAY SIGNIFICANCE ORDERED BY COMPETITIVE P-VALUE"
echo "${outfile}.gene_results.pdf: GENE RESULTS FIGURES"
echo "${outfile}.pathway_results.pdf: PATHWAY RESULTS FIGURES"
echo "${outfile}_GENES_AND_PATHWAYS.xls: EXCEL FILE, GENES AND PATHWAYS ASSOCIATIONS WITH REFERENCE PATHWAYS"

cp $pathname ${outfile}_pathwayids.txt

#if [[ ${kindOfPathway} = "MSigDB_CP_GO" ]];
#then
#	echo "MSigDB_CP_GO.genenames.grouped.10-1000: PATHWAYS OF SIZE 10-1000 WITH GENE NAMES"
#	echo "MSigDB_CP_GO.ensids.grouped.10-1000: PATHWAYS OF SIZE 10-1000 WITH ENS IDS"
#	echo "MSigDB_CP_GO_GenesH19: GENE POSITION REFERENCE FOR GENES WITHIN PATHWAYS"
#rm  ${outfile}.pathway_results.sets.out
#rm ${outfile}.pathway_results.genes.annot ${outfile}.pathway_results.genes.out ${outfile}.pathway_results.genes.out ${outfile}.pathway_results.genes.out.names ${outfile}.gene_results.genes.out ${outfile}.pathway_results.genes.raw ${outfile}.gene_results.genes.out.names ${outfile}.gene_results.genes.out.names.proteins ${outfile}.snps  
rm ${pathout} ${pathout}.genenames.grouped ${pathout}.genenames ${pathout}.ensids.grouped ${pathout}.ensids ${pathout}.ens.genes ${pathout}.genenames.grouped.atleast2 ${pathout}.ensids.grouped.atleast2 
	rm ${pathout}_GenesH19
	rm ${pathout}.genenames.grouped.10-1000
	rm ${pathout}.ensids.grouped.10-1000
#fi

