# Varia
Various useful genetic data processing scripts

## faSplitGap.awk
AWK script for spliting entries of a fasta file by gaps (N), into multiple fasta entries with >header_bin0, >header_bin1 etc. with gaps defined as sequence with at least one N

Replacement tool for the UCSC tool "faSplit gap" which has a bug and currently does not work (31 May 2018)

Usage: faSplitGap.awk < infile.fa > outfile.fa or (z)cat infile.fa(.gz) | faSplitGap.awk > outfile.fa
