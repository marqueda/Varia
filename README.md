# Varia
Various useful genetic data processing scripts

## faSplitGap.awk
AWK script for spliting entries of a fasta file by gaps (N), into multiple fasta entries with headers ">header_bin0 header:1-12345", ">header_bin1 header:12389-15678" etc. with gaps defined as sequence with at least one N. The right part of the new headers are 1-based coordinates from the original fasta file.

Replacement tool for the UCSC tool "faSplit gap" which has a bug and currently does not work (31 May 2018)

Usage: faSplitGap.awk < infile.fa > outfile.fa or (z)cat infile.fa(.gz) | faSplitGap.awk > outfile.fa
