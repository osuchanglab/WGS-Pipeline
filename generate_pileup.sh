#!/bin/bash
reference="reference"
insertsize=400
smaltpath="/pseudospace1/weisberga/bin/"
insertmin=$insertsize - 100
insertmax=$insertsize + 100
scriptdir="/pseudospace1/weisberga/Software/pileup_v0.6/ssaha_pileup"

#SMALT map, generate cigar files for each genome
for genome in `ls ./reads/*.fastq | sed 's/\.\.\/fastq\///' | sed 's/\.[12]\.fastq//' | sed 's/\.all\.fastq//' | grep -v reads | sort | uniq`; do
    if [ ! -e "$genome.$reference.cigar" ]; then
	command="smalt map -n 2 -l pe -f cigar -j $insertmin -i $insertmax -o ./$genome.$reference.cigar ./index/$reference ./reads/$genome.R1.fastq ./reads/$genome.R2.fastq"
    fi
done

#SSAHA2 pileup pipeline, generate pileup files for each genome
for genome in `ls *.cigar | sed 's/\.cigar//' | sort | uniq`; do
    if [ ! -e ../pileup/$genome.pileup ]; then
	if [ ! -s ${genome}_cigar_raw.dat ]; then
	    echo "cat $genome.cigar | egrep cigar > ${genome}_cigar_raw.dat"
	    cat $genome.cigar | egrep cigar > ${genome}_cigar_raw.dat
	fi
	if [ ! -s ${genome}_cigar.dat ]; then
	    echo "$scriptdir/ssaha_pileup/ssaha_pairs -insert $insertsize ${genome}_cigar_raw.dat ${genome}_cigar_unclean.dat"
	    $scriptdir/ssaha_pileup/ssaha_pairs -insert $insertsize ${genome}_cigar_raw.dat ${genome}_cigar_unclean.dat
	    echo "$scriptdir/ssaha_pileup/ssaha_clean -insert $insertsize ${genome}_cigar_unclean.dat ${genome}_cigar.dat"
	    $scriptdir/ssaha_pileup/ssaha_clean -insert $insertsize ${genome}_cigar_unclean.dat ${genome}_cigar.dat
	fi
	if [ ! -s $genome.dat ]; then
	    echo "cat ${genome}_cigar.dat | awk '{print $2}' > $genome.dat"
	    cat ${genome}_cigar.dat | awk '{print $2}' > $genome.dat
	fi
	if [ ! -s ${genome}_reads.fastq ]; then
	    echo "$scriptdir/other_codes/get_seqreads/get_seqreads $genome.dat ./reads/$genome.all.fastq ${genome}_reads.fastq"
	    $scriptdir/other_codes/get_seqreads/get_seqreads $genome.dat ./reads/$genome.all.fastq ${genome}_reads.fastq
	fi
	if [ ! -s ./pileup/$genome.pileup ]; then
	    echo "$scriptdir/ssaha_pileup/ssaha_pileup -solexa 1 -cons 1 ${genome}_cigar.dat /pseudospace1/davised/data/rf/fna_official_new/A44a.fna ${genome}_reads.fastq > ./pileup/$genome.pileup"
	    $scriptdir/ssaha_pileup/ssaha_pileup -solexa 1 -cons 1 ${genome}_cigar.dat ./index/A44a.fna ${genome}_reads.fastq > ./pileup/$genome.pileup
	    #rm ${genome}_cigar_raw.dat
	    #rm ${genome}_cigar_unclean.dat
	    #rm ${genome}_cigar.dat
	    #rm $genome.dat
	    #rm ${genome}_reads.fastq
	fi
    fi
done

