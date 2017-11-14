#!/bin/bash

#packages for R manhattan/qqplots
R -q -e "if (!'MASS' %in% installed.packages()) install.packages('MASS', repos='http://cran.rstudio.com/')"
R -q -e "if (!'lattice' %in% installed.packages()) install.packages('lattice', repos='http://cran.rstudio.com/')"
R -q -e "if (!'grid' %in% installed.packages()) install.packages('grid', repos='http://cran.rstudio.com/')"
R -q -e "if (!'calibrate' %in% installed.packages()) install.packages('calibrate', repos='http://cran.rstudio.com/')"
R -q -e "if (!'qqman' %in% installed.packages()) install.packages('qqman', repos='http://cran.rstudio.com/')"
R -q -e "if (!'ggplot2' %in% installed.packages()) install.packages('ggplot2', repos='http://cran.rstudio.com/')"
#packages for html tables/plots
R -q -e "if (!'googleVis' %in% installed.packages()) install.packages('googleVis', repos='http://cran.rstudio.com/')"

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

for i in *.r; do chmod u+x $i; done
for i in *.py; do chmod u+x $i; done
for i in *.pl; do chmod u+x $i; done


