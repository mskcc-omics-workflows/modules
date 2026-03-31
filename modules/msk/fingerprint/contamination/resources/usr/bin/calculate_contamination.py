#!/usr/bin/env python


"""
Calculates contamination from fingerprint table
"""

__author__       = "Hanan Salim"
__email__        = "salimh@mskcc.org"
__contributors__ = "Anne Marie Noronha (noronhaa@mskcc.org)"
__version__      = "0.1.0"
__status__       = "Dev"

import argparse
import pandas as pd
import numpy as np
import os
import sys

def major_contamination(tumor, depth_filter):
    tumor_filtered = get_coverage(tumor, depth_filter)

    homozygous = ['AA','CC','GG','TT','A','C','G','T']
    heterozygous = ~tumor_filtered['Genotype'].isin(homozygous)

    try:
        return sum(heterozygous)/tumor_filtered.shape[0]
    except Exception as e:
        return 0

def get_coverage(file, depth_filter):
    #print(file['Alleles'].str.split(' ', expand=True))
    file[['A1', 'A2']] = file['Alleles'].str.split(' ', expand=True)

    A1_count = list(file['A1'].str.split(':', expand=True)[1])
    A2_count = list(file['A2'].str.split(':', expand=True)[1])
    A1_int = list(map(int, A1_count))
    A2_int = list(map(int, A2_count))

    file['coverage'] = list(map(lambda x, y: x + y, A1_int, A2_int))

    filtered_data = file[file['coverage'] > depth_filter]

    return(filtered_data)

def minor_contamination(normal, tumor, depth_filter):
    homozygous_sites = normal.index[normal['MAF'] < .10]
    tumor_homozygous = tumor.loc[[i for i in homozygous_sites if i in tumor.index]]
    tumor_homozygous_filtered = get_coverage(tumor_homozygous, depth_filter)

    return tumor_homozygous_filtered['MAF'].mean()

def main():
    parser = argparse.ArgumentParser(prog=os.path.basename(sys.argv[0]), description='Calculate major and minor contamination')

    parser.add_argument('-t','--tumor',
                        required=True,
                        help='Tumor fingerprint table file')

    parser.add_argument('-n','--normal',
                        required=True,
                        help='Normal fingerprint table file')

    parser.add_argument('-o','--output',
                        required=True,
                        help='Output file for contamination results')

    parser.add_argument('-d','--depthfilter',
                        required=False,
                        default=20,
                        type=int,
                        help='Depth filter for coverage (default: 20)'
                        )

    parser.add_argument('--version',
                        action='version',
                        version='%(prog)s ' + __version__
                        )

    args = parser.parse_args()

    fields = ['Position', 'Alleles', 'Genotype', 'MAF']

    tumor = pd.read_csv(args.tumor, sep='\t',names=fields,header=0)
    tumor = tumor[~tumor['Position'].str.contains('X|Y', na=False)]
    tumor = tumor.set_index('Position')
    normal = pd.read_csv(args.normal, sep='\t',names=fields,header=0)
    normal = normal[~normal['Position'].str.contains('X|Y', na=False)]
    normal = normal.set_index('Position')

    major_contam = major_contamination(tumor, depth_filter=args.depthfilter)
    minor_contam = minor_contamination(normal, tumor, depth_filter=args.depthfilter)

    with open(args.output,'w') as f:
        f.write("Tumor\tNormal\tMajor_Contamination\tMinor_Contamination\n")
        f.write("{}\t{}\t{:.4f}\t{:.4f}\n".format(
            os.path.basename(args.tumor),
            os.path.basename(args.normal),
            major_contam,
            minor_contam))

if __name__== "__main__":
    main()
