#!/bin/bash
# BEGIN SGE OPTIONS DECLARATIONS
# Export all environment variables
#$ -V
#
# Your job name
#$ -N gubbins_all_ssaha2_drawer
#
# Shell Environment
#$ -S /bin/bash
#
# Use current working directory
#$ -cwd
#
# Set queue to use
#$ -q changall1
#
#Output files for stdout and stderr
#$ -o gubbins_all_smalt_drawer
#$ -e gubbins_all_smalt_drawere
#
# Ask for this many slots for multi-threaded jobs:
#$ -pe thread 1
#
# END SGE OPTIONS DECLARATIONS
#
PATH=/pseudospace1/weisberga/bin:/local/cluster/sge/bin/lx24-amd64:/raid1/home/pi/weisbeal/.local/bin:/pseudospace1/davised/libs/kSNP_Linux_package/kSNP:/pseudospace1/davised/bin/phylip-3.695/exe:/pseudospace1/davised/bin:/pseudospace1/davised/libs/bin:/local/cluster/sge/bin/lx24-amd64:/local/cluster/sge/bin/lx24-amd64:/bin:/local/cluster/jre1.6.0_23/bin:/home/pi/davised/scripts:/home/pi/davised/bin:/usr/bin:/local/cluster/bin:/usr/local/bin:/local/cluster/mpich/bin:/usr/local/share/ncbi/bin:/local/cluster/hdf5-1.8.13/hdf5/bin:/local/cluster/genome/bin:/local/cluster/RECON1.05/scripts:/local/cluster/MUMmer:/local/cluster/amos/bin:/local/cluster/velvet/velvet:/local/cluster/oases:/local/cluster/mira/bin:/local/cluster/abyss/bin:/local/cluster/cutadapt/bin:/local/cluster/edena2.1.1_linux64:/local/cluster/MAKER/bin:/local/cluster/mcl/bin:/local/cluster/YASRA/bin:/local/cluster/miRanda/bin:/local/cluster/ea-utils/bin:/local/cluster/RAxML/bin:/local/cluster/MOSAIK/bin:/local/cluster/hmmer/bin:/local/cluster/tmhmm/bin:/local/cluster/wgs/Linux-amd64/bin:/local/cluster/amber12/bin:/local/cluster/mpich2-1.2.1p1/bin:/usr/lib64/lam/bin:/local/cluster/mockler/bin:/local/cluster/carrington/bin:/local/cluster/variscan-2.0.3/bin/Linux-i386:/local/cluster/Roche/454/bin:/local/cluster/MaSuRCA/bin:/local/cluster/shore:/local/cluster/SHOREmap:/local/cluster/BEAST/bin:/local/cluster/BEDTools/bin:/local/cluster/genomemapper:/local/cluster/iprscan/bin:/local/cluster/trinityrnaseq:/local/cluster/Cerulean/bin:/local/cluster/Quake/bin:/local/cluster/glimmer/bin:/local/cluster/SPAdes-3.1.1-Linux/bin:/local/cluster/RAPSearch2.16_64bits/bin:/local/cluster/last-418/bin:/local/cluster/rnammer:/local/cluster/SHRiMP/bin:/local/cluster/homer/bin:/local/cluster/cd-hit:/local/cluster/augustus/bin:/local/cluster/ETA/bin:/local/cluster/structure_linux_console/bin:/local/cluster/stampy:/local/cluster/infernal/binaries:/local/cluster/rtax:/local/cluster/pandaseq/bin:/local/cluster/GARM:/local/cluster/AmpliconNoise/ampliconnoise/Scripts:/local/cluster/AmpliconNoise/ampliconnoise:/local/cluster/pplacer-v1.1:/local/cluster/microbiomeutil/WigeoN:/local/cluster/microbiomeutil/TreeChopper:/local/cluster/microbiomeutil/NAST-iEr:/local/cluster/microbiomeutil/ChimeraSlayer:/local/cluster/AmosCmp16Spipeline:/local/cluster/Tisean_3.0.0/bin:/local/cluster/allpathslg/bin:/local/cluster/NAMD:/local/cluster/vcf/bin:/local/cluster/iRODS/clients/icommands/bin:/local/cluster/SVMerge/bin:/local/cluster/pindel/bin:/local/cluster/breakdancer-1.1.2/bin:/local/cluster/cnD/bin:/local/cluster/nextclip/bin:/local/cluster/prokka-1.9/bin:/local/cluster/CEGMA_v2.5/bin:/local/cluster/julia-0.3.3/bin:/local/cluster/jnet/bin:/usr/X11R6/bin:/usr/X/bin:./:/pseudospace1/davised/scripts:/pseudospace1/davised/libs/sas/bin:/home/pi/davised/bin:/home/pi/davised/scripts:/usr/local/bin:/usr/bin:/bin:/local/cluster/bin:/local/cluster/genome/bin:/local/cluster/mpich/bin:/usr/local/share/ncbi/bin:/local/cluster/RAxML/bin:/local/cluster/velvet/velvet:/local/cluster/abyss/bin:/local/cluster/edena2.1.1_linux64:/local/cluster/RECON1.05/scripts:/usr/X11R6/bin:/usr/X/bin:/local/cluster/mockler/bin:/local/cluster/454/bin:/local/cluster/trinityrnaseq
export PATH
#
#
#The following auto-generated commands will be run by the execution node.
#We execute your command via /usr/bin/time with a custom format
#so that the memory usage and other stats can be tracked; note that
#GNU time v1.7 has a bug in that it reports 4X too much memory usage
echo "  Started on:           " `/bin/hostname -s` 
echo "  Started at:           " `/bin/date` 
/usr/bin/time -f " \\tFull Command:                      %C \\n\\tMemory (kb):                       %M \\n\\t# SWAP  (freq):                    %W \\n\\t# Waits (freq):                    %w \\n\\tCPU (percent):                     %P \\n\\tTime (seconds):                    %e \\n\\tTime (hh:mm:ss.ms):                %E \\n\\tSystem CPU Time (seconds):         %S \\n\\tUser   CPU Time (seconds):         %U " \
python2.7 /pseudospace1/weisberga/bin/gubbins_drawer.py -o ./smaltk13s2_all.snps.pdf -t smaltk13s2_all.final_tree.tre smaltk13s2_all.branch_base_reconstruction.embl
#python2.7 /pseudospace1/weisberga/bin/gubbins_drawer.py -o ./smaltk13s2_all.recombination.pdf -t smaltk13s2_all.final_tree.tre smaltk13s2_all.recombination_predictions.embl
echo "  Finished at:           " `date` 
