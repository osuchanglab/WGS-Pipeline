#!/bin/bash
echo "Generating pileup summary file"
pileup_summary_efficient.pl ./pileup/*.pileup > ./summary.tab
echo "Generating shared pileup file"
pileup_shared.pl ./summary.tab > ./shared.tab
echo "Generating shared fasta alignment"
pileup_shared2fasta.pl ./shared.tab > ./core_alignment.fasta
rm ./summary.tab
rm ./shared.tab
echo "Done"
