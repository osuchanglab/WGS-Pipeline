#!/bin/bash
set -e
echo "Generating pileup summary file"
./scripts/pileup_summary.pl ./pileup/*.pileup > ./summary.tab
echo "Generating shared pileup file"
./scripts/pileup_shared.pl ./summary.tab > ./shared.tab
echo "Generating shared fasta alignment"
./scripts/pileup_shared2fasta.pl ./shared.tab > ./core_alignment.fasta
echo "Done"
