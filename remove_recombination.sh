#!/bin/bash
set -e
echo "Running Gubbins to remove recombination"
echo -n "Please enter the number of cpus to use (default:1):"
read num_threads
re='^[0-9]+$'
if [ -z "$num_threads" ]; then
	num_threads=1
elif ! [[ $num_threads =~ $re ]] ; then
	echo "Error: Not a number, setting number of threads to 1"
	num_threads=1
fi
echo "Using $num_threads cpu threads"
echo -n "Please enter the maximum allowed % alignment gaps (default:30):"
read perc_gaps
if [ -z "$perc_gaps" ]; then
	perc_gaps=30
elif ! [[ $perc_gaps =~ $re ]] ; then
	echo "Error: Not a number, setting max. allowed % alignment gaps to 30"
	perc_gaps=30
fi
echo "Allowing up to $perc_gaps% gaps in alignment for each isolate"
echo "run_gubbins.py --threads $num_threads -f $perc_gaps core_alignment.fasta"
run_gubbins.py --threads $num_threads -f $perc_gaps core_alignment.fasta
echo "Drawing recombinant SNP map"
echo "gubbins_drawer.py -o ./core_alignment.recombinant_snps.pdf -t core_alignment.final_tree.tre core_alignment.branch_base_reconstruction.embl"
gubbins_drawer.py -o ./core_alignment.recombinant_snps.pdf -t core_alignment.final_tree.tre core_alignment.branch_base_reconstruction.embl
mv core_alignment.filtered_polymorphic_sites.fasta core_alignment_filtered_SNPs.fasta
echo "Done. Core alignment with recombinant SNPs removed was written to file core_alignment_filtered_SNPs.fasta"
