#! /usr/bin/env python

# Author: (c) David Marques, Nov 5th, 2017, Bern, Switzerland
# Written for Python 3.4.3
# Changelog:
# TODO's: expand to multiple chromosome

import argparse, os, re
import numpy as np

parser=argparse.ArgumentParser(description='parse Arlequin ARP file with DNA sequences to VCF file')
parser.add_argument('-a', '--arp', dest='a', help='Arlequin ARP file [required]', required=True)
parser.add_argument('-v', '--vcf', dest='v', help='VCF output file [required]', required=True)
args=parser.parse_args()

#infile=open("POP4.psmc.p10n30.bin1_1_1.arp",'r')
#out=open("test.vcf",'w')
infile=open(args.a,'r')
out=open(args.v,'w')
# Configure switches
pop=1
pos=0
chr=0
sam=0
inds=list()
g=1
nseq=10000000

for line in infile:
	if re.match(r"\tNbSamples",line):
		a=int((line.strip("\n").split("\t")[1]).split("=")[1])
	if re.match(r"\tGenotypicData",line):
		g=g+int((line.strip("\n").split("\t")[1]).split("=")[1])
	# Read chormosme and loci info
	if chr>0:
		chr+=1
		if chr==4:
			pos=line.strip("\n").strip("#").split(", ")
			chr=0
	if re.match(r"\#Number of independent chromosomes",line):
		chr=1
	# Read and print each sample
	if sam>0:
		if sam<nseq:
			if sam==2 and not ("outseq" in locals() or "outseq" in globals()):
				outseq=list(line.strip("\n").split("\t")[2])
			elif sam>=2:
				seq=list(line.strip("\n").split("\t")[2])
				outseq=[x+y for x,y in zip(outseq,seq)]
			sam+=1
		else:
			sam=0
			nseq=10000000
	if re.match(r"\t\tSampleSize",line):
		sam=1
		nseq=int(line.strip("\n").split("=")[1])
		inds.extend(["POP"+str(pop)+"."+str(x+1) for x in list(range(0,nseq))])
		nseq=nseq*g+2
		pop+=1

# Write VCF header
out.write("##fileformat=VCFv4.1\n")
# Write VCF field defintions
out.write("##FORMAT=<ID=GQ,Number=1,Type=Integer,Description=\"Genotype Quality\">\n")
out.write("##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">\n")
# Write definition of chromosome(s) and reference genome
out.write("##contig=<ID=chr1,length=100000000>\n")
out.write("##reference=file:///dummy/place.fa\n")
# Print last header line
out.write("#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t"+"\t".join(inds)+"\n")
# Print genotypes to VCF file
for i in range(0,(len(pos)-1)):
	geno=list(set(list(outseq[i])))
	if len(geno)==2:
		out.write("chr1\t"+str(pos[i])+"\t.\t"+"\t".join(set(list(outseq[i])))+"\t300\t.\t.\tGT:GQ"+re.sub(r"(\w)(\w)",r"\t\1|\2:99",re.sub(geno[1],"1",re.sub(geno[0],"0",outseq[i])))+"\n")

infile.close()
out.close()
