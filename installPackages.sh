#!/bin/bash

#packages for R manhattan/qqplots
sudo R -q -e "if(! 'MASS' %in% installed.packages()){r = getOption('repos');r['CRAN'] = 'http://cran.uk.r-project.org'; options(repos = r); install.packages('MASS')}"
sudo R -q -e "if(! 'lattice' %in% installed.packages()){r = getOption('repos');r['CRAN'] = 'http://cran.uk.r-project.org'; options(repos = r); install.packages('lattice')}"
sudo R -q -e "if(! 'grid' %in% installed.packages()){r = getOption('repos');r['CRAN'] = 'http://cran.uk.r-project.org'; options(repos = r); install.packages('grid')}"
sudo R -q -e "if(! 'calibrate' %in% installed.packages()){r = getOption('repos');r['CRAN'] = 'http://cran.uk.r-project.org'; options(repos = r); install.packages('calibrate')}"
sudo R -q -e "if(! 'qqman' %in% installed.packages()){r = getOption('repos');r['CRAN'] = 'http://cran.uk.r-project.org'; options(repos = r); install.packages('qqman')}"
sudo R -q -e "if(! 'ggplot2' %in% installed.packages()){r = getOption('repos');r['CRAN'] = 'http://cran.uk.r-project.org'; options(repos = r); install.packages('ggplot2')}"
sudo R -q -e "if(! 'googleVis' %in% installed.packages()){r = getOption('repos');r['CRAN'] = 'http://cran.uk.r-project.org'; options(repos = r); install.packages('googleVis')}"

#install perl packages 
cpan Text::CSV::Simple
cpan Spreadsheet::WriteExcel

#update script paths 
Rscriptdir=$(which Rscript |sed 's/\//\\\//g' );
Perldir=$(which perl |sed 's/\//\\\//g' )
Pythondir=$(which python |sed 's/\//\\\//g' )
for i in *.r; do sed -i.ba "1s/^.*$/\#\!${Rscriptdir}/" $i; done
for i in *.py; do sed -i.ba "1s/^.*$/\#\!${Pythondir}/" $i; done 
for i in *.pl; do sed -i.ba "1s/^.*$/\#\!${Perldir}/" $i; done
for i in *.sh; do sed -i.ba "s/\/users\/k1507306\/localperl\/bin\/perl/perl/g" $i; done
for i in *.r; do chmod u+x $i; done
for i in *.py; do chmod u+x $i; done
for i in *.pl; do chmod u+x $i; done


