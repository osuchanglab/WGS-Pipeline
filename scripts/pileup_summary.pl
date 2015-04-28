#!/usr/bin/perl
#Change $refgenome depending on the reference genome.
#Generates a pileup summary file from a set of provided pileup files generated by SSAHA2
#Can change the minimum number of reads and minimum agreement of those reads required for inclusion of a base call.

use warnings;
use strict;
use List::Util qw(max);

my @infiles;

die "No infiles given!" if (scalar(@ARGV) == 0);

@infiles = @ARGV;

my %names;
my %data;
my $minreads = 12;
my $minagreement = .75;
my $refgenome = 'A44a';
my @outdata;
my $header = 'gnl'; #change to a string unique to the header line to skip it

foreach my $infile (@infiles) {
    my $name = $infile;
    $name =~ s/.$refgenome.pileup//;
    $names{$name} = $infile;
}

foreach my $name (sort keys %names) {
    if (! -e $names{$name} ) {
	print STDERR $names{$name}." file is not found. Skipping...\n";
	next;
    } else {
	open INFILE, "<", $names{$name} or die $names{$name}." is unavailable : $!";
	while (<INFILE>) {
	    my $line = $_;
	    next if $line !~ /$header/; #Skip header line
	    chomp($line);
	    my ($refa,$refb,$pos,$reads,$refbase,$nA,$nC,$nG,$nT,@junk) = split(" ",$line); #split line into relevant data, ignore low quality calls
	    ${${$data{$refb}}{$pos}}{$refgenome} = $refbase; #store reference base
	    my $base = '';
	    if ($line =~ /Zero coverage/ || $reads < $minreads) {
		${${$data{$refb}}{$pos}}{$name} = '-'; #Set base to missing '-' if no reads map
		next;
	    }
	    my $max = max($nA,$nC,$nG,$nT); #Of the 4 bases, get the max value
	    if ($max/$reads < $minagreement) {
		${${$data{$refb}}{$pos}}{$name} = '-'; #Skip call if less than $minagreement reads agree
		next;		
	    }
	    
	    #Check to see which base has the max reads
	    if ($max == $nA) {
		$base = 'A';
	    } elsif ($max == $nC) {
		$base = 'C';
	    } elsif ($max == $nG) {
		$base = 'G';
	    } elsif ($max == $nT) {
		$base = 'T';
	    }
	    if (defined($base)) { #Should never be undefined, hopefully
		${${$data{$refb}}{$pos}}{$name} = $base; #Store base of aligned genome with position data
	    } else {
		print STDERR "There was a problem calculating the base.\n";
		${${$data{$refb}}{$pos}}{$name} = '-';
	    }
	}
	close INFILE;
    }
}

print join("\t",'contig','pos',$refgenome,(sort(keys(%names))))."\n";
foreach my $refcontig (sort keys %data) { #Get the data for each contig
    my $contig = $1 if $refcontig =~ /(contig00000[\d])/; #Assumes reference has contig0000\d and saves that data. Change if not the case.
    if ($contig) {
	my %tempdata = %{$data{$refcontig}}; #Get the hash to make printing easier
	foreach my $pos (sort {$a <=> $b} (keys(%tempdata))) { #Sort the hash by position
	    print join("\t",$contig,$pos,${$tempdata{$pos}}{$refgenome}); #print the contig, position, and reference base
	    foreach my $name (sort(keys(%names))) { #For each genome, print the aligned base call
		print "\t".${$tempdata{$pos}}{$name};
	    }
	    print "\n";
	}
    } else {
	print STDERR "No contig found! Skipping!\n";
	next;
    }
}