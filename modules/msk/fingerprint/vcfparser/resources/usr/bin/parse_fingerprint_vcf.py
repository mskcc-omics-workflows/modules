#!/usr/bin/env python
import argparse

"""
Converts fingerprint vcf to a formatted table
"""

__author__  = "Anne Marie Noronha"
__email__   = "noronhaa@mskcc.org"
__version__ = "0.1.0"
__status__  = "Dev"

import sys, os
from pysam import VariantFile    # version >= 0.15.2
from itertools import groupby

def usage():
    parser = argparse.ArgumentParser(prog='parse_fingerprint_vcf.py')
    parser.add_argument('--input','-i', help = 'input file', required = True)
    parser.add_argument('--samplename','-n', help = 'sample name', required = True)
    parser.add_argument('--output','-o', help = 'output file', required = True)
    parser.add_argument('--depth-filter','-d', default = 20, type = int, help = 'minimum read depth for outputting a minor allele frequency [default = 20]')
    parser.add_argument('--version','-v',action='version',version='%(prog)s ' + __version__, help="Show program's version number and exit.")
    return parser.parse_args()

def main():
    args = usage()

    fp_out_list = []

    vcf_in = VariantFile(args.input, "r")
    for vcf_rec in vcf_in.fetch():
        ref_allele = vcf_rec.ref
        alt_allele = vcf_rec.alts[0]
        ref_allele_count = vcf_rec.samples[args.samplename]["RD"]
        alt_allele_count = vcf_rec.samples[args.samplename]["AD"]
        if ref_allele_count >= alt_allele_count and ref_allele_count > 0:
            maf = alt_allele_count / float(ref_allele_count + alt_allele_count)
            if maf < .1:
                genotype = ref_allele*2
            else:
                genotype = ref_allele + alt_allele
        elif alt_allele_count > ref_allele_count:
            maf = ref_allele_count / float(ref_allele_count + alt_allele_count)
            if maf < .1:
                genotype = alt_allele*2
            #else: genotype = alt_allele + ref_allele
            else:
                genotype = ref_allele + alt_allele
        elif ref_allele_count == 0:
            genotype = "--"
        else:
            genotype = ref_allele + alt_allele
        if ref_allele_count + alt_allele_count < args.depth_filter or genotype == "--":
            maf = ""


        formatted_counts = "{}:{} {}:{}".format(ref_allele,ref_allele_count,alt_allele,alt_allele_count)

        locus = "{}:{}".format(vcf_rec.chrom,vcf_rec.pos)
        depth = vcf_rec.samples[args.samplename]["DP"]

        fp_out_list += [[locus,formatted_counts, genotype, maf]]

    with open(args.output,'w') as f:
        f.write("\t".join(['Locus', args.samplename + '_Counts', args.samplename + '_Genotypes', args.samplename + '_MinorAlleleFreq']) + "\n")
        for i in fp_out_list:
            f.write("\t".join([str(j) for j in i]) + "\n")

if __name__ == "__main__":
    main()
