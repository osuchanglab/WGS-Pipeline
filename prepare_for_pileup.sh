echo "Renaming read names to match the expected SMALT format (.p1k and .q1k)"
echo "The original read files are backed up in the folder ./reads/original_reads/"

`mkdir ./reads/original_reads`
`mv ./reads/*.fastq ./reads/original_reads/`

forwardreads=`ls -1 ./reads/original_reads/*.1.fastq`
for i in $forwardreads;  do
		reverseread=`echo $i | sed 's/.1.fastq/.2.fastq/'`
		forwardread=$i
		forwardreadname=`echo $forwardread | cut -f 4 -d /`
		reversereadname=`echo $reverseread | cut -f 4 -d /`
		dataset=`echo $forwardreadname | sed 's/.1.fastq//'`
		echo $dataset
		`cat $forwardread | awk '{gsub(" ", ".p1k ", $0); print $0}' > ./reads/$forwardreadname`
		`cat $reverseread | awk '{gsub(" ", ".q1k ", $0); print $0}' > ./reads/$reversereadname`
done

echo "Done"
