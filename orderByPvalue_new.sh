#!/bin/bash
#gawk '{min = $3; min= (min < $4 ? min : $4); print $3"\t"$1"\t"$2"\t"$4"\t"$5"\t"}' $1 | perl -e 'print sort { $a <=> $b } <>'
gawk '{print $6"\t"$1"\t"$2"\t"$3"\t"$8"\t"}' $1 | perl -e 'print sort { $a <=> $b } <>'
