# PathAnalyzor

This is wrapper for MAGMA, to easily analyze pathways.

1- Clone repository.

2- Download ancestry reference directory (g1000_ref.tar.gz). Decompress it inside main directory.

3- Inside main directory, install packages by running "./InstallPackages.sh"

4- Simple command to run all pathways: ./runPath.sh nameofgwas nameofoutput samplesize

Example:
./runPath.sh example_GWAS/Alzheimer ./example 10000

If you want to use the drug data (not yet published), please contact us (helena.gaspar@kcl.ac.uk).
If you use our scripts for your paper, please remember to cite us (https://github.com/hagax8/PathAnalyzor, by Héléna A. Gaspar, King's College London)
