#!/bin/bash
set -e
echo "Running Gubbins to remove recombination"
echo "run_gubbins.py --threads 1 -f 30 core_alignment.fasta"
run_gubbins.py --threads 1 -f 30 core_alignment.fasta
echo "Drawing recombinant SNP map"
echo "gubbins_drawer.py -o ./core_alignment.recombinant_snps.pdf -t core_alignment.final_tree.tre core_alignment.branch_base_reconstruction.embl"
gubbins_drawer.py -o ./core_alignment.recombinant_snps.pdf -t core_alignment.final_tree.tre core_alignment.branch_base_reconstruction.embl
mv core_alignment.filtered_polymorphic_sites.fasta core_alignment_filtered_SNPs.fasta
echo "Done. Core alignment with recombinant SNPs removed was written to file core_alignment_filtered_SNPs.fasta"
