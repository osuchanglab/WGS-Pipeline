#!/bin/bash
python2.7 run_gubbins.py --threads 1 -f 30 core_alignment.fasta
python2.7 gubbins_drawer.py -o ./core_alignment.recombinant_snps.pdf -t core_alignment.final_tree.tre core_alignment.branch_base_reconstruction.embl
mv core_alignment.filtered_polymorphic_sites.fasta core_alignment_filtered_SNPs.fasta

