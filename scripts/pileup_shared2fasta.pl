#!/usr/bin/perl
use warnings;
use strict;

my $infile = shift;

die "No infile found. Check settings and try again.\n" if ( ! -e $infile);

open INFILE, "<$infile" or die "Unable to open file $infile : $!";

my %data;
my @genomes;

while (<INFILE>) {
    my $line = $_;
    chomp($line);
    my ($contig, $pos, @data) = split("\t",$line); #separate position, identifier, and sequence data
    if ($pos =~ /pos/) { #If it's a header line, save the genome IDs into @genomes array
	@genomes = @data;
    } else { #If it's not a header line...
	for (my $i = 0; $i < scalar(@data); $i++) { #Use a counter to match the position data to the genomes data
	    push(@{$data{$genomes[$i]}},$data[$i]); #Push sequence data into the genome-named array, with $i matching base to genome
	}
    }
}

close INFILE;

foreach my $genome (sort keys %data) { #Get the genome names, which are the keys to the data hash
    print ">".$genome."\n".join('',@{$data{$genome}})."\n"; #print concatenated sequence data for each genome
}
