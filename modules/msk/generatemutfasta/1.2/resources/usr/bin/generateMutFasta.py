#!/usr/bin/env python3

import os
import sys
import argparse
import traceback
import pandas as pd
import logging
from mutalyzer.normalizer import normalize

VERSION = 1.2

#######################
### FASTA with mutated peptides
#######################

#
# initialize loggers
#
logger = logging.getLogger("generate_fasta")
logger.setLevel(logging.DEBUG)


def main():
    prog_description = "Construct mutated peptide sequences from HGVSc"
    prog_epilog = "\n"

    parser = argparse.ArgumentParser(
        description=prog_description,
        epilog=prog_epilog,
        formatter_class=argparse.RawDescriptionHelpFormatter,
        add_help=True,
    )
    required_arguments = parser.add_argument_group("Required arguments")
    required_arguments.add_argument(
        "--sample_id",
        required=True,
        help="sample_id used to limit neoantigen prediction to identify mutations "
        "associated with the patient in the MAF (column 16). ",
    )
    required_arguments.add_argument(
        "--output_dir", required=True, help="output directory"
    )
    required_arguments.add_argument(
        "--maf_file",
        required=True,
        help="expects a maf file with HGVSc and transcripts",
    )

    optional_arguments = parser.add_argument_group("Optional arguments")
    optional_arguments.add_argument(
        "--peptide_lengths",
        required=False,
        help="comma-separated numbers indicating the lengths of peptides to generate. Default: 9,10",
    )
    optional_arguments.add_argument(
        "-v", "--version", action="version", version="%(prog)s {}".format(VERSION)
    )

    args = parser.parse_args()

    maf_file = str(args.maf_file)
    output_dir = str(args.output_dir)
    sample_id = str(args.sample_id)
    peptide_lengths = [9, 10, 11]
    sample_path_pfx = output_dir + "/" + sample_id
    mutated_sequences_fa = sample_path_pfx + ".MUT.sequences.fa"
    WT_sequences_fa = sample_path_pfx + ".WT.sequences.fa"

    mutations = []
    out_fa = open(mutated_sequences_fa, "w")
    out_WT_fa = open(WT_sequences_fa, "w")

    console_formatter = logging.Formatter(
        "%(asctime)s: %(levelname)s: %(message)s", datefmt="%m-%d-%Y %H:%M:%S"
    )

    # logfile handler
    log_file_name = f"{sample_id}_generate_mut_fasta.log"
    handler_file = logging.FileHandler(output_dir + f"/{log_file_name}", mode="w")
    handler_file.setLevel(logging.DEBUG)
    handler_file.setFormatter(console_formatter)
    logger.addHandler(handler_file)

    # stdout handler
    handler_stdout = logging.StreamHandler(sys.stdout)
    handler_stdout.setFormatter(console_formatter)
    handler_stdout.setLevel(logging.INFO)
    logger.addHandler(handler_stdout)

    logger.info("Starting generate mut fasta")
    logger.info("\tLog file: " + output_dir + f"/{log_file_name}")
    logger.info("\t--maf_file: " + maf_file)
    logger.info("\t--output_dir: " + output_dir)

    ## generate .debug.fa for debugging purposes.
    debug_out_fa = open(sample_path_pfx + ".mutated_sequences.debug.fa", "w")

    try:

        logger.info("Reading MAF file and constructing mutated peptides...")
        maf_df = skip_lines_start_with(
            maf_file, "#", low_memory=False, header=0, sep="\t"
        )
        n_muts = n_non_syn_muts = n_missing_tx_id = 0
        for _, row in maf_df.iterrows():

            n_muts += 1

            mut = mutation(row)

            if mut.is_non_syn():
                n_non_syn_muts += 1

            response = mut.generate_translated_sequences(max(peptide_lengths))

            if response == -1:
                n_missing_tx_id += 1

            if len(mut.mt_altered_aa) > 5:
                id_string = (
                    str(mut.maf_row["Transcript_ID"])
                    + " Variant "
                    + str(mut.maf_row["Chromosome"])
                    + ":"
                    + str(mut.maf_row["Start_Position"])
                    + "-"
                    + str(mut.maf_row["End_Position"])
                    + " Ref:"
                    + str(mut.maf_row["Reference_Allele"])
                    + " Alt:"
                    + str(mut.maf_row["Tumor_Seq_Allele2"])
                )
                out_fa.write(">" + mut.identifier_key + " " + id_string + "\n")
                out_fa.write(mut.mt_altered_aa + "\n")
                out_WT_fa.write(">" + mut.identifier_key + " " + id_string + "\n")
                out_WT_fa.write(mut.wt_altered_aa + "\n")

                ### write out WT/MT CDS + AA for debugging purposes
                debug_out_fa.write(">" + mut.identifier_key + "_M\n")
                debug_out_fa.write("mt_altered_aa: " + mut.mt_altered_aa + "\n")
                debug_out_fa.write("wt_full_aa: " + mut.wt_aa + "\n")
                debug_out_fa.write("mt_full_aa: " + mut.mt_aa + "\n")
            mutations.append(mut)

        out_fa.close()
        debug_out_fa.close()

        logger.info("\tMAF mutations summary")
        logger.info("\t\t# mutations: " + str(n_muts))
        logger.info(
            "\t\t# non-syn: "
            + str(n_non_syn_muts)
            + " (# missing from cache: "
            + str(n_missing_tx_id)
            + ")"
        )

    except Exception:
        logger.error("Error while generating mutated peptides")
        logger.error(traceback.format_exc())
        exit(1)


# skip the header lines that start with "#"
def skip_lines_start_with(fle, junk, **kwargs):
    if os.stat(fle).st_size == 0:
        raise ValueError("File is empty")
    with open(fle) as f:
        pos = 0
        cur_line = f.readline()
        while cur_line.startswith(junk):
            pos = f.tell()
            cur_line = f.readline()
        f.seek(pos)
        return pd.read_csv(f, **kwargs)


#
# mutation class holds each row in the maf
#
class mutation(object):
    maf_row = None
    wt_aa = ""
    mt_altered_aa = ""
    mt_altered_aa = ""
    identifier_key = ""

    def __init__(self, maf_row):
        self.maf_row = maf_row

        ##ENCODING FASTA ID FOR USE IN MATCHING LATER
        ALPHABET = [
            "A",
            "B",
            "C",
            "D",
            "E",
            "F",
            "G",
            "H",
            "I",
            "J",
            "K",
            "L",
            "M",
            "N",
            "O",
            "P",
            "Q",
            "R",
            "S",
            "T",
            "U",
            "V",
            "W",
            "X",
            "Y",
            "Z",
        ]

        variant_type_map = {
            "missense_mutation": "M",
            "nonsense_nutation": "X",
            "silent_mutation": "S",
            "silent": "S",
            "frame_shift_ins": "I+",
            "frame_shift_del": "I-",
            "in_frame_ins": "If",
            "in_frame_del": "Id",
            "splice_site": "Sp",
        }

        position = int(str(self.maf_row["Start_Position"])[0:2])

        if position < 26:
            encoded_start = ALPHABET[position]
        elif position < 100:

            encoded_start = ALPHABET[position // 4]

        position = int(str(self.maf_row["Start_Position"])[-2:])

        if position < 26:
            encoded_end = ALPHABET[position]
        elif position < 100:

            encoded_end = ALPHABET[position // 4]

        sum_remaining = sum(int(d) for d in str(self.maf_row["Start_Position"])[2:-2])

        encoded_position = encoded_start + ALPHABET[sum_remaining % 26] + encoded_end

        if self.maf_row["Tumor_Seq_Allele2"] == "-":
            # handles deletion
            if len(self.maf_row["Reference_Allele"]) > 3:
                Allele2code = self.maf_row["Reference_Allele"][0:3]
            else:
                Allele2code = self.maf_row["Reference_Allele"]

        elif len(self.maf_row["Tumor_Seq_Allele2"]) > 1:
            # handles INS and DNP
            if len(self.maf_row["Tumor_Seq_Allele2"]) > 3:
                Allele2code = self.maf_row["Tumor_Seq_Allele2"][0:3]
            else:
                Allele2code = self.maf_row["Tumor_Seq_Allele2"]

        else:
            # SNPs
            Allele2code = self.maf_row["Tumor_Seq_Allele2"]

        if self.maf_row["Variant_Classification"].lower() in variant_type_map:
            self.identifier_key = (
                str(self.maf_row["Chromosome"])
                + encoded_position
                + "_"
                + variant_type_map[(self.maf_row["Variant_Classification"]).lower()]
                + Allele2code
            )
        else:

            self.identifier_key = (
                str(self.maf_row["Chromosome"])
                + encoded_position
                + "_"
                + "SY"
                + Allele2code
            )

    ### Check if the variant_classification is among those that can generate a neoantigen
    def is_non_syn(self):
        types = [
            "Frame_Shift_Del",
            "Frame_Shift_Ins",
            "In_Frame_Del",
            "In_Frame_Ins",
            "Missense_Mutation",
            "Nonstop_Mutation",
        ]

        return self.maf_row["Variant_Classification"] in types and not pd.isnull(
            self.maf_row["HGVSp_Short"]
        )

    # function that parses the HGVSc and constructs the WT and mutated coding sequences for the given mutation.
    def generate_translated_sequences(self, pad_len=10):
        if not self.is_non_syn():
            return None

        hgvsc = self.maf_row["HGVSc"]
        transcript = self.maf_row["Transcript_ID"]
        if hgvsc and "c" in str(hgvsc):
            mutalyzer_response = normalize(f"{transcript}:{hgvsc}")
        else:
            return None
        if "errors" in mutalyzer_response:
            error_obj = mutalyzer_response["errors"][0]
            logger.warning(
                "Mutalyzer error: "
                + f"{transcript}:{hgvsc} "
                + error_obj["code"]
                + ", "
                + error_obj["details"]
            )
            return -1
        mt = mutalyzer_response["protein"]["predicted"]
        wt = mutalyzer_response["protein"]["reference"]

        ### identify regions of mutation in WT and MT sequences.
        ### logic is to match the wt and mt sequences first from the beginning until a mismatch is found; and, then,
        ### start from the end of both sequences until a mismatch is found. the intervening sequence represents the WT and MT sequences
        ### Note, aside from missenses, the interpretation of WT sequence is ambiguous.
        len_from_start = len_from_end = 0

        ## from start
        for i in range(0, min(len(wt), len(mt))):
            len_from_start = i
            if wt[i : i + 1] != mt[i : i + 1]:
                break

        ## from end
        wt_rev = wt[::-1]
        mt_rev = mt[::-1]
        for i in range(0, min(len(wt), len(mt))):
            len_from_end = i
            if (
                len_from_end + len_from_start >= min(len(wt), len(mt))
                or wt_rev[i : i + 1] != mt_rev[i : i + 1]
            ):
                break

        wt_start = len_from_start
        wt_end = len(wt) - len_from_end

        mt_start = len_from_start
        mt_end = len(mt) - len_from_end

        self.wt_aa = wt
        self.mt_aa = mt

        self.wt_altered_aa = wt[
            max(0, wt_start - pad_len + 1) : min(len(wt), wt_end + pad_len - 1)
        ]
        self.mt_altered_aa = mt[
            max(0, mt_start - pad_len + 1) : min(len(mt), mt_end + pad_len - 1)
        ]


if __name__ == "__main__":
    main()
