#!/usr/bin/perl
#Generates a pileup summary file with only the positions shared by (1 - $fraction) genomes.  Includes SNPs and non-SNP positions.
use warnings;
use strict;

die ("No input given! Give summary file produced by pileup_summary.pl!") if scalar(@ARGV) == 0;

my $infile = shift;

die ("Unable to find file $infile. Check input and try again.") if (! -e $infile);

open INFILE, "$infile" or die "$infile is unavailable : $!";

my @order;
my $gencount;
my $fraction = 0.10;

while (<INFILE>) {
    my $line = $_;
    chomp($line);
    if ($line =~ /pos/) {
	my ($junk1, $junk2);
	($junk1, $junk2, @order) = split("\t",$line);
	$gencount = @order;
	print $line."\n";
    } else {
	my ($contig,$pos,@data) = split("\t",$line);
	my $count = 0;
	foreach my $base (@data) {
	    $count++ if $base eq '-';
	}
	print $line."\n" if ($count <= $gencount*$fraction);
    }
}

close INFILE;
