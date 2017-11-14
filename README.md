# PathAnalyzor

This is wrapper for MAGMA (https://ctg.cncr.nl/software/magma), to easily analyze pathways from MSigDB (http://software.broadinstitute.org/gsea/msigdb), Open Targets (https://www.opentargets.org/), gene families (https://www.genenames.org/) and drug gene-sets (reference soon to be available; if you want to use the drug data, please contact us).

1- Clone repository.

2- Download ancestry reference directory ([g1000_ref.tar.gz](https://drive.google.com/file/d/1jEJsH1vRnaNlkvCJ504FMBFXdHeA6BBl/view?usp=sharing)). Decompress it inside main directory.

3- Inside main directory, install packages by running "./InstallPackages.sh"

4- Simple command to run all pathways: ./runPath.sh nameofgwas nameofoutput samplesize

Example:
./runPath.sh example_GWAS/Alzheimer ./example 10000

If you want to use the drug data in your paper, please contact us (helena.gaspar@kcl.ac.uk).
If you use our scripts for your paper, please remember to cite us (https://github.com/hagax8/PathAnalyzor, by Héléna A. Gaspar, Social, Genetic & Developmental Psychiatry Centre, King's College London)



