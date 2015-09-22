#!/bin/bash
set -e
reference="reference"
insertsize=400
insertmin=0
insertmax=1000
scriptdir="/usr/local/bin/pileup_v0.6/ssaha_pileup"
integerregex='^[0-9]+$'

#Get user input for insert size and pileup script dir
echo "Generating pileup files for each genome in ./pileup/"
echo "Please enter the location of the ssaha_pileup scripts folder"
echo "Example: /usr/local/bin/pileup_v0.6/ssaha_pileup"
echo -n "ssaha_pileup script directory:"
read user_script_dir
if [ ! -d "$user_script_dir" ]; then
    echo "ERROR: Directory $user_script_dir does not exist. exiting." >&2; exit 1
else 
    command -v $user_script_dir/ssaha_pileup/ssaha_pairs > /dev/null 2>&1 || { echo >&2 "ERROR: Cannot find ssaha_pileup executable ssaha_pairs at $user_script_dir/ssaha_pileup/ssaha_pairs, check your path and try again. exiting"; exit 1; }
fi
scriptdir=$user_script_dir


#Check if executables exist first
command -v smalt >/dev/null 2>&1 || { echo >&2 "SMALT executable not found. Make sure smalt is in your path and try again. exiting."; exit 1; }


#SMALT map, generate cigar files for each genome
for genome in `ls ./reads/*.fastq | sed 's/\.[12]\.fastq//' | sed 's/\.all\.fastq//' | sed 's/\.\/reads\///' | sort | uniq`; do
    echo "Analyzing genome $genome"
    
    echo -n "Please enter the library minimum insert size for $genome (0):"
    read current_min_insertsize
    if  [[ $current_min_insertsize =~ $integerregex ]] ; then
    	insertmin=$current_min_insertsize
	else
		insertmin=0
	fi

    echo -n "Please enter the library maximum insert size for $genome (1000):"
	read current_max_insertsize
	if  [[ $current_max_insertsize =~ $integerregex ]] ; then
		insertmax=$current_max_insertsize
	else
		insertmax=1000
	fi
    
    echo "$genome: Mapping reads to reference genome using SMALT"
    if [ ! -e "$genome.cigar" ]; then
	echo "$genome: smalt map -n 2 -l pe -f cigar -j $insertmin -i $insertmax -o ./$genome.cigar ./index/$reference ./reads/$genome.1.fastq ./reads/$genome.2.fastq"
	smalt map -n 2 -l pe -f cigar -j $insertmin -i $insertmax -o ./$genome.cigar ./index/$reference ./reads/$genome.1.fastq ./reads/$genome.2.fastq
    fi

    #SSAHA2 pileup pipeline, generate pileup files for each genome
    echo "$genome: Generating a pileup file using SSAHA_pileup"
    if [ ! -e ./pileup/$genome.pileup ]; then
	if [ ! -s ${genome}_cigar_raw.dat ]; then
	    echo "$genome: cat $genome.cigar | egrep cigar > ${genome}_cigar_raw.dat"
	    cat $genome.cigar | egrep cigar > ${genome}_cigar_raw.dat
	fi
	if [ ! -s ${genome}_cigar.dat ]; then
	    echo "$genome: $scriptdir/ssaha_pileup/ssaha_pairs -insert $insertsize ${genome}_cigar_raw.dat ${genome}_cigar_unclean.dat"
	    $scriptdir/ssaha_pileup/ssaha_pairs -insert $insertsize ${genome}_cigar_raw.dat ${genome}_cigar_unclean.dat
	    echo "$genome: $scriptdir/ssaha_pileup/ssaha_clean -insert $insertsize ${genome}_cigar_unclean.dat ${genome}_cigar.dat"
	    $scriptdir/ssaha_pileup/ssaha_clean -insert $insertsize ${genome}_cigar_unclean.dat ${genome}_cigar.dat
	fi
	if [ ! -s $genome.dat ]; then
	    echo "$genome: cat ${genome}_cigar.dat | awk '{print $2}' > $genome.dat"
	    cat ${genome}_cigar.dat | awk '{print $2}' > $genome.dat
	fi
	if [ ! -e "./reads/$genome.all.fastq" ]; then
           echo "$genome: cat ./reads/$genome.1.fastq ./reads/$genome.2.fastq > ./reads/$genome.all.fastq"
           cat ./reads/$genome.1.fastq ./reads/$genome.2.fastq > ./reads/$genome.all.fastq
	fi
	if [ ! -s ${genome}_reads.fastq ]; then
	    echo "$genome: $scriptdir/other_codes/get_seqreads/get_seqreads $genome.dat ./reads/$genome.all.fastq ${genome}_reads.fastq"
	    $scriptdir/other_codes/get_seqreads/get_seqreads $genome.dat ./reads/$genome.all.fastq ${genome}_reads.fastq
	fi
	if [ ! -s ./pileup/$genome.pileup ]; then
	    echo "$genome: $scriptdir/ssaha_pileup/ssaha_pileup -solexa 1 -cons 1 ${genome}_cigar.dat ./index/reference.fna ${genome}_reads.fastq > ./pileup/$genome.pileup"
	    $scriptdir/ssaha_pileup/ssaha_pileup -solexa 1 -cons 1 ${genome}_cigar.dat ./index/reference.fna ${genome}_reads.fastq > ./pileup/$genome.pileup
	fi
    fi
done

