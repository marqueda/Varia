#! /bin/awk -f

# AWK script for
# spliting entries of a fasta file by gaps (N),
# into multiple fasta entries with >header_bin0, >header_bin1 etc.
# with gaps defined as sequence with at least one N
#
# Replacement tool for the UCSC tool "faSplit gap" which has a bug and currently does not work (31 May 2018)
#
# Usage: faSplitGap.awk < infile.fa > outfile.fa or (z)cat infile.fa(.gz) | faSplitGap.awk > outfile.fa
# (c) David Marques 31 May 2018

BEGIN{
 # Set chromosome name, piece counter to one, start position to one and length to zero
 c="";h="";d="";i=0;p=1;m=0
}
{
 # FASTA HEADER: print previous header / data line, store new header information
 if(match($N,/>/)){
  # Print previous header / data lines if applicable
  if(length(d)>0){
   print h" "c":"p"-"p+length(d)-1
   print d
  }
  # Store new chromosome name
  sub(">","",$N)
  c=$N
  # Reset piece counter, start position, data line and length and deactivate gap mask
  i=0;p=1;l=0;m=0;d=""
  # Store new header information
  h=">"c"_bin"i
 }else{
  # DATA LINE: check for presence of gap (N)
  if(match($N,/N/)){
   # YES GAP: split line into single characters
   split($N,n,"")
   # Loop through line characters
   for(j=1;j<=length(n);j++){
    # Check wheter gap has started already
    if(match(n[j],/N/)){
     # GAP: decide whether JUST STARTED or CONTINUED
     if(m==0 && length(d)>0){
      # GAP JUST STARTED: print previous header / data line, store new header information
      print h" "c":"p"-"p+length(d)-1
      print d
      # Update piece counter, start position, reset data line
      i+=1;p+=length(d);d=""
      h=">"c"_bin"i
     }else{
      # GAP CONTINUED: update position
      p+=1
     }
     # Activate gap mask
     m=1
    }else{
     # NO GAP YET: add to data line
     d=d""n[j]
     # Inactivate gap mask if active and update position
     if(m==1){m=0;p+=1}
    }
   }
  }else{
   # NO GAP: elongate data line, inactivate gap mask
   d=d""$N; m=0
  }
 }
}END{
 # LAST LINE
 # Print previous header / data lines if applicable
 if(length(d)>0){
  print h" "c":"p"-"p+length(d)-1
  print d
 }
}
