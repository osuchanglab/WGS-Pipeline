#!/bin/bash
set -e
#RAxML default settings, either change here or during runtime
random_seed=$RANDOM
mlsearch_replicates=20
bootstrap_replicates=1000
#bootstrap mode, either -b for regular bootstrap, -x for rapid bootstrap
full_bootstrap="-b"
rapid_bootstrap="-x"
bootstrap_mode=$full_bootstrap
snpmodel="ASC_GTRGAMMA --asc-corr=lewis"
fullmodel="GTRGAMMA"
model=$fullmodel
raxmlexecutable="raxmlHPC"
#example for pthreads compiled with AVX support
#threads=1
#raxmlexecutable="raxmlHPC-AVX-PTHREADS -T $threads"




########## Do not change beyond this point #######################

numregex='^[0-9]+$'

#Get user input to change parameters
echo -n "Enter the number of tree searches to perform (default: $mlsearch_replicates): "
read user_mlsearch_reps
if [ ! -z "$user_mlsearch_reps" ] && [[ $user_mlsearch_reps =~ $numregex ]]; then
	mlsearch_replicates=$user_mlsearch_reps
fi
echo "Will perform $mlsearch_replicates tree searches."

echo -n "Enter the number of bootstrap replicates to perform (default: $bootstrap_replicates):"
read user_bootstrap_reps
if [ ! -z "$user_bootstrap_reps" ] && [[ $user_bootstrap_reps =~ $numregex ]]; then
    bootstrap_replicates=$user_bootstrap_reps
fi
echo "Will perform $bootstrap_replicates bootstrap replicates."

echo -n "Do you want to perform a rapid bootstrap instead of the full bootstrap? (default: no) [y/N]:"
read user_rapid_boot_response
case $user_rapid_boot_response in
    [yY][eE][sS]|[yY]) 
		bootstrap_mode=$rapid_bootstrap
		echo "Will perform rapid bootstrap"
		;;
	*)
		bootstrap_mode=$full_bootstrap
		echo "Will perform full bootstrap"
		;;
esac

#if gubbins was run, use core_alignment_filtered_SNPs.fasta otherwise core_alignment.fasta
if [ -s core_alignment_filtered_SNPs.fasta ]; then
	#Use gubbins SNP alignment and Ascertainment bias correcting model
	input_alignment="./core_alignment_filtered_SNPs.fasta"
	model=$snpmodel
	echo "Using Gubbins output for input alignment with ascertainment bias-correcting model"
else
	#Did not run Gubbins, use regular alignment
	input_alignment="./core_alignment.fasta"
	model=$fullmodel
fi

echo "Generating a maximum likelihood phylogeny with bootstrap support for the core alignment"
#Do RAxML ML searches
echo "Performing $mlsearch_replicates maximum likelihood tree searches"
echo "$raxmlexecutable -m $model -p $random_seed -N $mlsearch_replicates -s $input_alignment -n core_alignment.tre > raxml_mlsearch.out"
$raxmlexecutable -m $model -p $random_seed -N $mlsearch_replicates -s $input_alignment -n core_alignment.tre > raxml_mlsearch.out
#Do RAxML bootstrap searches
echo "Performing $bootstrap_replicates bootstrap tree searches"
echo "$raxmlexecutable -m $model -p $random_seed $bootstrap_mode $random_seed -N $bootstrap_replicates -s $input_alignment -n core_alignment_bootstrap.tre > raxml_bootstrap.out"
$raxmlexecutable -m $model -p $random_seed $bootstrap_mode $random_seed -N $bootstrap_replicates -s $input_alignment -n core_alignment_bootstrap.tre > raxml_bootstrap.out
#Map bootstrap support values onto branches of the best ML search tree
echo "Mapping bootstrap support values onto branches of the best ML search tree"
echo "$raxmlexecutable -m $model -p $random_seed -f b -t RAxML_bestTree.core_alignment.tre -z RAxML_bootstrap.core_alignment_bootstrap.tre -n core_alignment_raxml.tre > raxml_bootstrap_mapping.out"
$raxmlexecutable -m $model -p $random_seed -f b -t RAxML_bestTree.core_alignment.tre -z RAxML_bootstrap.core_alignment_bootstrap.tre -n core_alignment_raxml.tre > raxml_bootstrap_mapping.out

echo "Tree file written to ./core_alignment_raxml.tre"
echo "Done."
