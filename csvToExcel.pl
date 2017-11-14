#/users/k1507306/localperl/bin/perl
#
use strict;
use warnings;

use Spreadsheet::WriteExcel;
use Text::CSV::Simple;

my $numberOfCSVFiles = int(shift);
my $outfile = shift . ".xls";
my $workbook = Spreadsheet::WriteExcel->new($outfile);

sub usage {
	    print "CONVERTING CSV FILES TO XLS: ./csvToExcel.pl NumberOfCSVFiles outfile infile1.csv tabName1 infile2.csv tabName2 (...)\n";
	}

sub error {
	print "error: incorrect input file";
	exit();
}
my $bold = $workbook->add_format();

usage();

for(my $i=0;$i<$numberOfCSVFiles;$i++){
my $infile = shift;
my $parser = Text::CSV::Simple->new({sep_char => "\t", binary => 1});
my @data = $parser->read_file($infile);
error() unless defined $infile && -f $infile;
my $headers = shift @data;
my $subject = shift;
$bold->set_bold(1);
import_data($workbook, $subject, $headers, \@data);
}



sub import_data {
    my $workbook  = shift;
    my $base_name = shift;
    my $colums    = shift;
    my $data      = shift;
    my $limit     = shift || 50_000;
    my $start_row = shift || 1;
    my $worksheet = $workbook->add_worksheet($base_name);
    $worksheet->add_write_handler(qr[\w], \&store_string_widths);
    my $w = 1;
    $worksheet->write('A' . $start_row, $colums, ,$bold);
    my $i = $start_row;
    my $qty = 0;
    for my $row (@$data) {
	#$row =~ s/\'/\"\'\"/r;
        #$row =~ s/\w/\"\'\"/r;
        $qty++;
        if ($i > $limit) {
             $i = $start_row;
             $w++;
             $worksheet = $workbook->add_worksheet("$base_name - $w");
             $worksheet->write('A1', $colums,$bold);
        }
        $worksheet->write($i++, 0, $row);
    }
    autofit_columns($worksheet);
    print "In your spreadsheet, the tab $base_name contains $qty rows.\n";
    return $worksheet;
}

sub autofit_columns {

    my $worksheet = shift;
    my $col       = 0;

    for my $width (@{$worksheet->{__col_widths}}) {

        $worksheet->set_column($col, $col, $width) if $width;
        $col++;
    }
}


######################################################################
sub store_string_widths {

    my $worksheet2 = shift;
    my $col2       = $_[1];
    my $token     = $_[2];


    return if not defined $token;       # Ignore undefs.
    return if $token eq '';             # Ignore blank cells.
    return if ref $token eq 'ARRAY';    # Ignore array refs.
    return if $token =~ /^=/;           # Ignore formula

    # Ignore numbers
    #return if $token =~ /^([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+
    # urls.
    return if $token =~ m{^[fh]tt?ps?://};
    return if $token =~ m{^mailto:};
    return if $token =~ m{^(?:in|ex)ternal:};

    # We store the string width as data in the Worksheet object. We us
    my $old_width    = $worksheet2->{__col_widths}->[$col2];
    my $string_width = string_width($token);

    if (not defined $old_width or $string_width > $old_width) {
        # You may wish to set a minimum column width as follows.
        #return undef if $string_width < 10;

        $worksheet2->{__col_widths}->[$col2] = $string_width;
    }

    # Return control to write();
    return undef;
}


######################################################################
sub string_width {
    return length $_[0];
}
