#!/usr/bin/env python3

import argparse

VERSION = 1.0

PAN_HEADER = [
    "pos",
    "MHC",
    "peptide",
    "core",
    "OF",
    "Gp",
    "Gl",
    "Ip",
    "Il",
    "icore",
    "Identity",
    "score_el",
    "rank_el",
    "score_ba",
    "rank_ba",
    "affinity",
]
STAB_PAN_HEADER = [
    "pos",
    "HLA",
    "peptide",
    "Identity",
    "Pred",
    "Thalf(h)",
    "%Rank_Stab",
]


def netMHCpan_out_reformat(netMHCpanoutput, mut, stab, prefix):
    file_li = []
    stab_prefix = ""
    type_prefix = "WT"
    if stab:
        stab_prefix = "stab"
    if mut:
        type_prefix = "MUT"
    outfilename = "{}_netmHC{}panoutput.{}.tsv".format(prefix, stab_prefix, type_prefix)
    with open(netMHCpanoutput, "r") as file:
        # data = file.read()
        for line in file:
            # Remove leading whitespace
            line = line.lstrip()
            # Check if the line starts with a digit
            if line == "":
                pass
            elif line[0].isdigit():
                # Print or process the line as needed
                match = (
                    line.strip().replace(" <= WB", "").replace(" <= SB", "")
                )  # strip to remove leading/trailing whitespace
                splititem = match.split()
                tab_separated_line = "\t".join(splititem)
                file_li.append(tab_separated_line)
    if stab:
        header = "\t".join(STAB_PAN_HEADER) + "\n"
    else:
        header = "\t".join(PAN_HEADER) + "\n"
    with open(outfilename, "w") as file:
        file.writelines(header)
        for item in file_li:
            file.writelines(item)
            file.writelines("\n")


def parse_args():
    parser = argparse.ArgumentParser(description="Process input files and parameters")
    parser.add_argument(
        "--netMHCpan_output", required=True, help="Path to netMHC output"
    )
    parser.add_argument("--type_MUT", action="store_true", help="Output is a MUT type")
    parser.add_argument(
        "--from_STAB",
        action="store_true",
        help="Output is from netmhcstab",
    )
    parser.add_argument("--id", required=True, help="Prefix to label the output")
    parser.add_argument(
        "-v", "--version", action="version", version="%(prog)s {}".format(VERSION)
    )

    return parser.parse_args()


def main(args):
    netMHCpan_out_reformat(
        args.netMHCpan_output, args.type_MUT, args.from_STAB, args.id
    )


if __name__ == "__main__":
    args = parse_args()
    main(args)
