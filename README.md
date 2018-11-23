# Varia
Various useful genetic data processing scripts

## faSplitGap.awk
AWK script for spliting entries of a fasta file by gaps (N), into multiple fasta entries with headers ">header_bin0 header:1-12345", ">header_bin1 header:12389-15678" etc. with gaps defined as sequence with at least one N. The right part of the new headers are 1-based coordinates from the original fasta file.

Replacement tool for the UCSC tool "faSplit gap" which has a bug and currently does not work (31 May 2018)

Usage: faSplitGap.awk < infile.fa > outfile.fa or (z)cat infile.fa(.gz) | faSplitGap.awk > outfile.fa

## header_recoverfromstacks.sh
This script recovers the header line of each read in a FASTQ file after STACKS demultiplexing back to the original format "@Machine:run:runid:lane:xposition:yposition:zposition 1:Y:0:" This is important for subsequent base quality score recalibration.

Usage: header_recoverfromstacks.sh <path_to_folder_demultiplexed> <file_barcodes_names> <file_raw_data>
        1) path to FOLDER containing demultiplexed fastq-files <sample_AGCTA.fq>
        2) FILE with barcodes of the library with correct path (2 columns, tab-delimited 'RAD-ID TAB barcode')
        3) FILE, raw data file from sequencing center with correct path (uncompressed or gzipped fastq/fq-format).

This script will generate files with the new name given in the barcodes_names file. The files are written into the folder from where the script is run. Be sure to add a slash '/' at the end of the path name, e.g. ./ or GQI20/
