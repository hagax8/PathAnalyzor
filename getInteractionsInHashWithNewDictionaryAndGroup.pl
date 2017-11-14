#!/usr/bin/perl
use strict;
use warnings;

my %interactions;
my %translation;
my $fileTrain = $ARGV[0];
my $dictionary = $ARGV[1];
my $outfile = $ARGV[2];

my $outfile1 = join ".",$outfile,"genenames";
my $outfile2 = join ".",$outfile,"ensids";
my $outfile3 = join ".",$outfile,"genenames","grouped";
#only this file will be used for pathway analysis:
my $outfile4 = join ".",$outfile,"ensids","grouped";

# tab-separated pathway file
open (FH, "< $fileTrain") or die "Cannot open $fileTrain";
while (<FH>){
	chomp($_);
	my @words = split '\t', $_;
	my $nDimensions = $#{words}+1;
        for (my $j=1; $j<$nDimensions;$j++){
		$interactions{$words[0]}{$words[$j]}=1
	}	 
}
close FH or die "Cannot close $fileTrain: $!";


#tab-separated name/ensid dictionary: name first column, followed by one or several tab-separated ENS ids
open (FH, "< $dictionary") or die "Cannot open $dictionary";
while (<FH>){
        chomp($_);
        my @enswords = split '\t', $_;
        my $nDimensions = $#{enswords}+1;
        for (my $j=1; $j<$nDimensions;$j++){
        $translation{$enswords[0]}{$enswords[$j]}=1
}
}
close FH or die "Cannot close $dictionary: $!";

#translate names into ens ids
my %finaltranslation;


foreach my $molecule (sort keys %interactions) {
	 foreach my $dimension (sort keys %{ $interactions{$molecule} }) {
		    foreach my $ensid (sort keys %{ $translation{$dimension} }) {
			 $finaltranslation{$molecule}{$ensid}=1
}
}
}

#print final result
open (my $FH, "> $outfile2") or die "Cannot open $outfile2";
foreach my $molecule (sort keys %finaltranslation) {
	print $FH "$molecule";
       foreach my $ensid (sort keys %{ $finaltranslation{$molecule} }) {
              print $FH "\t$ensid";
              }
   print $FH "\n";
}
close $FH or die "Cannot close $outfile2: $!";

open ($FH, "> $outfile1") or die "Cannot open $outfile1";
foreach my $molecule (sort keys %interactions) {
        print $FH "$molecule";
       foreach my $nameid (sort keys %{ $interactions{$molecule} }) {
              print $FH "\t$nameid";
              }
   print $FH "\n";
}
close $FH or die "Cannot close $outfile1: $!";



#group molecules with the same ENS path
my %groupedmoleculesENS;
my $thevar;
my $thevarnames;
my $thecount=0;
foreach my $molecule (sort keys %finaltranslation) {
	$thevar="";
	$thevarnames="";
	$thecount=0;
	foreach my $ensid (sort keys %{ $finaltranslation{$molecule} }) {
		if($thecount==0){$thevar=$ensid;$thecount=1}else
		{$thevar=join "\t",$thevar,$ensid;}
	}
	$thecount=0;
	 foreach my $nameid (sort keys %{ $interactions{$molecule} }) {
		 if($thecount==0){$thevarnames=$nameid;$thecount=1}else
{$thevarnames=join "\t",$thevarnames,$nameid};
		 }
	$groupedmoleculesENS{$thevar}{$molecule}=$thevarnames;
}

#print final result
open ($FH, "> $outfile4") or die "Cannot open $outfile4";
foreach my $path (sort keys %groupedmoleculesENS) {
	$thecount=0;
       foreach my $molecule (sort keys %{ $groupedmoleculesENS{$path} }) {
	       if ($thecount==0){print $FH "$molecule";$thecount=1}
	       else {
              print $FH ";$molecule";
     		 }
              }
      print $FH "\t$path";
      print $FH "\n";
}
close $FH or die "Cannot close $outfile4: $!";

open ($FH, "> $outfile3") or die "Cannot open $outfile3";
my $tempmol;
foreach my $path (sort keys %groupedmoleculesENS) {
         $thecount=0;
       foreach my $molecule (sort keys %{ $groupedmoleculesENS{$path} }) {
               if ($thecount==0){print $FH "$molecule"}
               else {
              print $FH ";$molecule";
                 }
                 $thecount+=1;
              $tempmol=$molecule;}
print $FH "\t$groupedmoleculesENS{$path}{$tempmol}";
      print $FH "\n";
}
close $FH or die "Cannot close $outfile3: $!";


