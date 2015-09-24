#!/bin/bash
set -e
#RAxML default settings, either change here or during runtime
random_seed=$RANDOM
mlsearch_replicates=20
bootstrap_replicates="autoMRE"
#bootstrap mode, either -b for regular bootstrap, -x for rapid bootstrap
full_bootstrap="b"
rapid_bootstrap="x"
bootstrap_mode=$full_bootstrap
snpmodel="ASC_GTRGAMMA"
fullmodel="GTRGAMMA"
model=$fullmodel
raxmlexecutable="raxmlHPC"
threads=1

threaded=0
SSE3=0
AVX=0
lewis=0

########## Do not change beyond this point #######################

numregex='^[0-9]+$'

#Get user input to change parameters
echo -n -e "Which version of RAxML would you like to use? (default:raxmlHPC):\n\t(1)  raxmlHPC\n\t(2)  raxmlHPC-SSE3\n\t(3)  raxmlHPC-AVX\n\t(4)  raxmlHPC-PTHREADS\n\t(5)  raxmlHPC-PTHREADS-SSE3\n\t(6)  raxmlHPC-PTHREADS-AVX\nEnter a number:"
read raxml_version_num
case $raxml_version_num in 
	1)
		raxmlexecutable="raxmlHPC"
		;;
	2)
		raxmlexecutable="raxmlHPC-SSE3"
		SSE3=1
		;;
	3)
		raxmlexecutable="raxmlHPC-AVX"
		AVX=1
		;;
	4)
		raxmlexecutable="raxmlHPC-PTHREADS"
		threaded=1
		;;
	5)
		raxmlexecutable="raxmlHPC-PTHREADS-SSE3"
		threaded=1
		SSE3=1
		;;
	6)
		raxmlexecutable="raxmlHPC-PTHREADS-AVX"
		threaded=1
		AVX=1
		;;
	*)
		raxmlexecutable="raxmlHPC"
		;;
esac
case $raxml_version_num in
	[4-6])
		echo "Using a pthreads version of RAxML"
		echo -n "Enter the number of cpu processors to use (2):"
		read input_threads
		if [ ! -z "$input_threads" ] && [[ $input_threads =~ $numregex ]]; then
        	threads=$input_threads
		else
			threads=2
		fi
		raxmlexecutable="$raxmlexecutable"
		echo "Will use $threads cpu threads"
		;;
esac

echo "Will use $raxmlexecutable"

#Check if executables exist first
command -v $raxmlexecutable  >/dev/null 2>&1 || { echo >&2 "$raxmlexecutable executable not found. Make sure RAxML is in your path and try again. exiting."; exit 1; }


#Check if RAxML is new enough to handle ascertainment bias correction (version >= 8.1.7)
raxml_version=`$raxmlexecutable -v | grep -oP 'This is RAxML version \d+.\d+.\d+' | grep -oP '\d+.\d+.\d+'`
split_version=(${raxml_version//./ })
major_version=${split_version[0]}
minor_version=${split_version[1]}
sub_version=${split_version[2]}

if [[ $major_version -lt 8 ]]; then
	echo "A RAxML version with ascertainment bias correction is required, please compile a newer version of RAxML (> 8.1.7) and try again. exiting."
	exit 1
elif [[ $major_version == 8 ]] && [[ $minor_version -lt 1 ]]; then
	echo "A RAxML version with ascertainment bias correction is required, please compile a newer version of RAxML (> 8.1.7) and try again. exiting."
	exit 1
elif [[ $major_version == 8 ]] && [[ $minor_version == 1 ]] && [[ $sub_version -lt 7 ]]; then
	echo "A RAxML version with ascertainment bias correction is required, please compile a newer version of RAxML (> 8.1.7) and try again. exiting."
	exit 1
fi

echo -n "Enter the number of tree searches to perform (default: $mlsearch_replicates): "
read user_mlsearch_reps
if [ ! -z "$user_mlsearch_reps" ] && [[ $user_mlsearch_reps =~ $numregex ]]; then
	mlsearch_replicates=$user_mlsearch_reps
fi
echo "Will perform $mlsearch_replicates tree searches."

echo -n "Enter the number of bootstrap replicates to perform or a cutoff criterion (default: $bootstrap_replicates):"
read user_bootstrap_reps
if [ ! -z "$user_bootstrap_reps" ] && ( [[ $user_bootstrap_reps =~ $numregex ]] || [[ $user_bootstrap_reps =~ (autoMRE|autoFC|autoMR|autoMRE_IGN) ]] ); then
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
	lewis=1
	echo "Using Gubbins output for input alignment with ascertainment bias-correcting model"
else
	#Did not run Gubbins, use regular alignment
	input_alignment="./core_alignment.fasta"
	model=$fullmodel
fi

raxmlscriptflags="-runid phylogeny -alignment $input_alignment -model $model"
if [[ $threaded == 1 ]]; then
	raxmlscriptflags="$raxmlscriptflags -PTHREADS $threads"
fi
if [[ $lewis == 1 ]]; then
	raxmlscriptflags="$raxmlscriptflags -lewis"
fi
if [[ $AVX == 1 ]]; then
	raxmlscriptflags="$raxmlscriptflags -AVX"
elif [[ $SSE3 == 1 ]]; then
	raxmlscriptflags="$raxmlscriptflags -SSE3"
fi

echo "Optimizing initial maximum likelihood parameters (output: raxml_initial.out)"
./scripts/emlsa-raxml.pl -initial $raxmlscriptflags > raxml_initial.out 
echo "Performing maximum likelhood tree searches (output: raxml_mlsearch.out)"
./scripts/emlsa-raxml.pl -mlsearch $mlsearch_replicates $raxmlscriptflags > raxml_mlsearch.out
echo "Performing non-parametric bootstrap replicate searches (output: raxml_bootstrap.out)"
./scripts/emlsa-raxml.pl -bootstrap $bootstrap_replicates $raxmlscriptflags -boottype $bootstrap_mode > raxml_bootstrap.out
echo "Mapping bootstrap values to the best ML search tree"
./scripts/emlsa-raxml.pl -final $raxmlscriptflags > raxml_final.out
cp ./phylogeny/trees/RAxML_bipartitions.phylogeny.final.nwk ./core_alignment_raxml.tre
echo "Tree file written to ./core_alignment_raxml.tre"
echo "Done."
