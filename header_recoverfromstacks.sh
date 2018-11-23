#! /bin/bash
# 19 May 2014, (c) David Marques
# Modified by Joana Meier
# This script recovers the header line of each read in a FASTQ file after STACKS demultiplexing
# back to the original format "@Machine:run:runid:lane:xposition:yposition:zposition 1:Y:0:"
# This is important for subsequent base quality score recalibration.

# Prints information on usage of this script
echo -e "Usage: header_recoverfromstacks.sh <path_to_folder_demultiplexed> <file_barcodes_names> <file_raw_data>\n\t1) path to FOLDER containing demultiplexed fastq-files <sample_AGCTA.fq>\n\t2) FILE with barcodes of the library with correct path (2 columns, tab-delimited 'RAD-ID TAB barcode')\n\t3) FILE, raw data file from sequencing center with correct path (uncompressed or gzipped fastq/fq-format)."
echo "This script will generate files with the new name given in the barcodes_names file. The files are written into the folder from where the script is run"
echo "Be sure to add a slash '/' at the end of the path name, e.g. ./ or GQI20/ "

# This clause checks if 3 input arguments were given
if [ $# -lt 3 ]
then
	echo -e "Error: Please provide all three input arguments: <path_to_folder_demultiplexed> <file_barcodes_names> <file_raw_data>"
	exit 1
fi

# These clauses check that all of the given inputs lead to existing folders and files
if [ -d $1 ]
then
	echo ""
else
	echo "Error: Path to folder with demultiplexed fq-files not found, please enter correct path."
	exit 1
fi


if [ -f $2 ]
then
	echo ""
else
	echo "Error: barcode_names file not found, please enter correct path and file name."
	exit 1
fi

if [ -f $3 ]
then
	echo ""
else
	echo "Error: Raw file not found, please enter correct path and filename."
	exit 1
fi

# Creates regular expression search pattern for the STACKS-format header, used later in the loop
pattern="^@[0-9]_.*_.*_.*$"
echo $pattern

# Gets name of machine/run/runid form the raw fastq-file which was lost in the STACKS-process.
# This clause allows to read the header from both compressed and uncompressed raw files.
if [ -f ${3%.gz} ]
then
	machinename=$(head -1 $3 | cut -f 1-3 -d ":")
else
	machinename=$(zcat $3 | head -1 | cut -f 1-3 -d ":")
fi
echo "Machine name found: "$machinename


# Edit 2015/10/22: Runs dos2unix on the barcode file, because many people forget to do that after Excel/Windows
dos2unix $2

# Loops through barcode file to recover the header of every fq-file (output from process_radtags)
# with the name sample_AGCTG.fq (AGCTG or others is barcode from barcode file) to the original format
# (relevant to base-quality recalibration) and gives the file the name RAD-ID.fastq (e.g. 12345.troutsaane3.GQI33.fastq).

for i in $(cat $2 | sed 's/\t/\_/')
do
	echo "handling "$1"sample_"${i#*_}".fq"
	infile=$1"sample_"${i#*_}".fq"
	echo $infile
	if grep -lq $pattern $infile
	then
		sed "s/\@\(.\)\_\(.*\)\_\(.*\)\_\(.*\).\(.\)/"$machinename"\:\1\:\2\:\3:\4 \5\:Y\:0\:/" $infile > ${i%_*}.fastq
	else
		echo -e "File sample_"${i#*_}".fq does not exist and individual "${i%_*}" has thus not been converted."
	fi
done

echo "If everything looks ok, delete the sample_*.fq files"
