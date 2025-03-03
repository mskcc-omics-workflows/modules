#!/usr/bin/env python3

import os, sys
import argparse, re
import traceback
import pandas as pd
import logging, logging.handlers
import gzip
import copy

VERSION = 1.1

#######################
### FASTA with mutated peptides
#######################


def main():
    prog_description = (
        "# Neoantigen prediction pipeline. Four main steps: \n"
        "\t\t(1) Genotype HLA using POLYSOLVER, \n"
        "\t\t(2) Constructed mutated peptide sequences from HGVSp/HGVSc \n"
        "\t\t(3) Run NetMHCpan \n"
        "\t\t(4) Gather results and generate: \n"
        "\t\t\t\t- <sample_id>.neoantigens.maf: original maf with neoantigen prediction columns added \n"
        "\t\t\t\t- <sample_id>.all_neoantigen_predictions.txt: all the predictions made for all peptides by both the algorithms \n"
    )
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
        "--maf_file", required=True, help="expects a CMO maf file (post vcf2maf.pl)"
    )
    required_arguments.add_argument(
        "--CDS_file", required=True, help="expects a fa.gz file"
    )
    required_arguments.add_argument(
        "--CDNA_file", required=True, help="expects a fa.gz file"
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
    reference_cds_file = str(args.CDS_file)
    reference_cdna_file = str(args.CDNA_file)
    peptide_lengths = [9, 10, 11]
    sample_path_pfx = output_dir + "/" + sample_id
    mutated_sequences_fa = sample_path_pfx + ".MUT_sequences.fa"
    WT_sequences_fa = sample_path_pfx + ".WT_sequences.fa"

    mutations = []
    out_fa = open(mutated_sequences_fa, "w")
    out_WT_fa = open(WT_sequences_fa, "w")

    #
    # initialize loggers
    #
    logger = logging.getLogger("neoantigen")
    logger.setLevel(logging.DEBUG)
    console_formatter = logging.Formatter(
        "%(asctime)s: %(levelname)s: %(message)s", datefmt="%m-%d-%Y %H:%M:%S"
    )

    # logfile handler
    handler_file = logging.FileHandler(output_dir + "/neoantigen_run.log", mode="w")
    handler_file.setLevel(logging.DEBUG)
    handler_file.setFormatter(console_formatter)
    logger.addHandler(handler_file)

    # stdout handler
    handler_stdout = logging.StreamHandler(sys.stdout)
    handler_stdout.setFormatter(console_formatter)
    handler_stdout.setLevel(logging.INFO)
    logger.addHandler(handler_stdout)

    logger.info("Starting neoantigen prediction run")
    logger.info("\tLog file: " + output_dir + "/neoantigen_run.log")
    logger.info("\t--maf_file: " + maf_file)
    logger.info("\t--output_dir: " + output_dir)

    ## generate .debug.fa for debugging purposes.
    debug_out_fa = open(sample_path_pfx + ".mutated_sequences.debug.fa", "w")

    try:
        logger.info("Loading reference CDS/cDNA sequences...")
        cds_seqs = load_transcript_fasta(reference_cds_file)
        cdna_seqs = load_transcript_fasta(reference_cdna_file)
        logger.info("Finished loading reference CDS/cDNA sequences...")

        logger.info("Reading MAF file and constructing mutated peptides...")
        maf_df = skip_lines_start_with(
            maf_file, "#", low_memory=False, header=0, sep="\t"
        )
        n_muts = n_non_syn_muts = n_missing_tx_id = 0
        for index, row in maf_df.iterrows():
            cds_seq = ""
            cdna_seq = ""

            n_muts += 1
            tx_id = row["Transcript_ID"]
            if tx_id in cds_seqs:
                cds_seq = cds_seqs[tx_id]

            if tx_id in cdna_seqs:
                cdna_seq = cdna_seqs[tx_id]

            mut = mutation(row, cds_seq, cdna_seq)

            if mut.is_non_syn():
                n_non_syn_muts += 1

            if cds_seq == "":
                n_missing_tx_id += 1

            if cds_seq != "" and mut.is_non_syn():
                mut.generate_translated_sequences(max(peptide_lengths))

            if len(mut.mt_altered_aa) > 5:
                out_fa.write(">" + mut.identifier_key + "_M\n")
                out_fa.write(mut.mt_altered_aa + "\n")
                out_WT_fa.write(">" + mut.identifier_key + "_W\n")
                out_WT_fa.write(mut.wt_altered_aa + "\n")

                ### write out WT/MT CDS + AA for debugging purposes
                debug_out_fa.write(">" + mut.identifier_key + "_M\n")
                debug_out_fa.write("mt_altered_aa: " + mut.mt_altered_aa + "\n")
                debug_out_fa.write("wt_full_cds: " + mut.wt_cds + "\n")
                debug_out_fa.write("wt_full_aa: " + mut.wt_aa + "\n")
                debug_out_fa.write("mt_full_cds: " + mut.mt_cds + "\n")
                debug_out_fa.write("mt_full_aa: " + mut.mt_aa + "\n")
            mutations.append(mut)

        out_fa.close()
        debug_out_fa.close()

        logger.info("\tMAF mutations summary")
        logger.info("\t\t# mutations: " + str(n_muts))
        logger.info(
            "\t\t# non-syn: "
            + str(n_non_syn_muts)
            + " (# with missing CDS: "
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


def load_transcript_fasta(fa_file):
    seqs = dict()
    if fa_file[-3 : len(fa_file)] == ".gz":
        lines = gzip.open(fa_file, "rb").readlines()
    else:
        lines = open(fa_file).readlines()
    idx = 0
    while idx < len(lines):
        line = lines[idx]
        m = re.search("^>(ENST\d+)\s", line.decode("utf-8"))
        transcript_id = ""
        if not m:
            sys.exit("Error parsing transcript file " + fa_file + " at line: " + line)
        else:
            transcript_id = m.group(1)

        idx = idx + 1
        seq_str = ""
        while idx < len(lines) and not re.match("^>ENST", lines[idx].decode("utf-8")):
            seq_str = seq_str + lines[idx].decode("utf-8").strip()
            idx = idx + 1
            seqs[transcript_id] = seq_str

    return seqs


class neopeptide(object):
    row = None
    algorithm = ""
    version = ""
    hla_allele = ""
    peptide = ""
    core = ""
    icore = ""
    score_el = 0
    rank_el = 100
    score_ba = 0
    rank_ba = 0
    binding_affinity = 10000
    best_binder_for_icore_group = ""
    binder_class = ""
    is_in_wt_peptidome = False

    def __init__(self, row):
        self.row = row
        self.algorithm = row["algorithm"]
        self.version = row["version"]
        self.hla_allele = row["hla_allele"]
        self.peptide = row["peptide"]
        self.core = row["core"]
        self.icore = row["icore"]
        self.score_el = row["score_el"]
        self.rank_el = row["rank_el"]
        self.score_ba = row["score_ba"]
        self.rank_ba = row["rank_ba"]
        self.binding_affinity = row["affinity"]
        self.binder_class = row["binder_class"]
        self.best_binder_for_icore_group = row["best_binder_for_icore_group"]
        self.is_in_wt_peptidome = row["is_in_wt_peptidome"]

    def is_strong_binder(self):
        if self.binder_class == "Strong Binder":
            return True
        return False

    def is_weak_binder(self):
        if self.binder_class == "Weak Binder":
            return True
        return False


#
# class to hold the list of neopeptides and helper functions to identify strong/weak binders
#
class binding_predictions(object):
    neopeptides = None

    def __init__(self, neopeptides):
        self.neopeptides = neopeptides

    def add_neopeptide(self, np):
        self.neopeptides.append(np)

    def get_best_per_icore(self):
        return [x for x in self.neopeptides if x.best_binder_for_icore_group]

    def get_strong_binders(self):
        return [x for x in self.get_best_per_icore() if x.is_strong_binder()]

    def get_weak_binders(self):
        return [x for x in self.get_best_per_icore() if x.is_weak_binder()]

    def get_all_binders(self):
        return [
            x
            for x in self.get_best_per_icore()
            if x.is_strong_binder() or x.is_weak_binder()
        ]

    def get_best_binder(self):
        if len(self.get_best_per_icore()) == 0:
            return None
        return sorted(
            self.get_best_per_icore(), key=lambda x: x.rank_el, reverse=False
        )[0]


#
# mutation class holds each row in the maf and has
#
class mutation(object):
    maf_row = None
    cds_seq = ""
    cdna_seq = ""
    wt_cds = ""
    wt_aa = ""
    wt_altered_aa = ""
    mt_cds = ""
    mt_aa = ""
    mt_altered_aa = ""
    identifier_key = ""
    predicted_neopeptides = None

    def __init__(self, maf_row, cds_seq, cdna_seq):
        self.maf_row = maf_row
        self.cds_seq = cds_seq
        self.cdna_seq = cdna_seq
        self.predicted_neopeptides = binding_predictions([])

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

    ### helper function #source: stackoverflow.
    def reverse_complement(self, dna):
        complement = {"A": "T", "C": "G", "G": "C", "T": "A"}
        return "".join([complement[base] for base in dna[::-1]])

    ### helper function to translate cDNA sequence
    @staticmethod
    def cds_to_aa(cds):
        # https://www.geeksforgeeks.org/dna-protein-python-3/
        codon_table = {
            "ATA": "I",
            "ATC": "I",
            "ATT": "I",
            "ATG": "M",
            "ACA": "T",
            "ACC": "T",
            "ACG": "T",
            "ACT": "T",
            "AAC": "N",
            "AAT": "N",
            "AAA": "K",
            "AAG": "K",
            "AGC": "S",
            "AGT": "S",
            "AGA": "R",
            "AGG": "R",
            "CTA": "L",
            "CTC": "L",
            "CTG": "L",
            "CTT": "L",
            "CCA": "P",
            "CCC": "P",
            "CCG": "P",
            "CCT": "P",
            "CAC": "H",
            "CAT": "H",
            "CAA": "Q",
            "CAG": "Q",
            "CGA": "R",
            "CGC": "R",
            "CGG": "R",
            "CGT": "R",
            "GTA": "V",
            "GTC": "V",
            "GTG": "V",
            "GTT": "V",
            "GCA": "A",
            "GCC": "A",
            "GCG": "A",
            "GCT": "A",
            "GAC": "D",
            "GAT": "D",
            "GAA": "E",
            "GAG": "E",
            "GGA": "G",
            "GGC": "G",
            "GGG": "G",
            "GGT": "G",
            "TCA": "S",
            "TCC": "S",
            "TCG": "S",
            "TCT": "S",
            "TTC": "F",
            "TTT": "F",
            "TTA": "L",
            "TTG": "L",
            "TAC": "Y",
            "TAT": "Y",
            "TAA": "_",
            "TAG": "_",
            "TGC": "C",
            "TGT": "C",
            "TGA": "_",
            "TGG": "W",
        }
        protein = ""

        for i in range(0, len(cds), 3):
            codon = cds[i : i + 3]
            if len(codon) != 3:
                ## This is unusual; in some cases in Ensembl the CDS length is not a multiple of 3. Eg: ENST00000390464
                ## For this reason, decided not to throw an error and just stop translating if the CDS ends with a non-triplet
                # print 'CDS ends with non-triplet: ' + codon + ' ' + cds
                break
            if codon_table[codon] == "_":  # stop codon reached
                break
            protein += codon_table[codon]
        return protein

    # function that parses the HGVSc and constructs the WT and mutated coding sequences for the given mutation.
    def generate_translated_sequences(self, pad_len=10):
        if not self.is_non_syn():
            return None

        ## append the 3'UTR to the CDS -- to account for non stop mutations and indels that shift the canonical stop
        if not self.cds_seq in self.cdna_seq:
            print(
                "Skipping because the CDS is not contained within cDNA. Note: only 2 transcripts/peptides are like this"
            )
            return None

        hgvsc = self.maf_row["HGVSc"]
        position, ref_allele, alt_allele, sequence, hgvsc_type = [-1, "", "", "", "ONP"]

        if re.match(r"^c\.(\d+).*([ATCG]+)>([ATCG]+)$", hgvsc):
            position, ref_allele, alt_allele = re.match(
                r"^c\.(\d+).*(\w+)>(\w+)", hgvsc
            ).groups()

        elif re.match(r"^c\.(\d+).*del([ATCG]+)ins([ATCG]+)$", hgvsc):
            position, ref_allele, alt_allele = re.match(
                r"^c\.(\d+).*del([ATCG]+)ins([ATCG]+)$", hgvsc
            ).groups()

        elif re.match(r"^c\.(\d+).*(dup|ins|del|inv)([ATCG]+)$", hgvsc):
            position, hgvsc_type, sequence = re.match(
                r"^c\.(\d+).*(dup|ins|del|inv)([ATCG]+)$", hgvsc
            ).groups()

        else:
            sys.exit("Error: not one of the known HGVSc strings: " + hgvsc)

        position = int(position) - 1
        if hgvsc_type in "dup,ins":
            alt_allele = sequence
        elif hgvsc_type == "del":
            ref_allele = sequence
        elif hgvsc_type == "inv":
            ref_allele = sequence
            alt_allele = self.reverse_complement(sequence)

        ## start of mutated region in CDS
        cds = re.search(self.cds_seq + ".*", self.cdna_seq).group()

        seq_5p = cds[0:position]
        seq_3p = cds[position : len(cds)]

        # print self.hgvsp + '\t' + self.variant_class + '\t' + self.variant_type + '\t' + self.ref_allele + '\t' + self.alt_allele + \
        #      '\t' + self.cds_position + '\nFull CDS: ' + self.cds_seq + '\nSeq_5: ' + seq_5p + '\nSeq_3' + seq_3p + '\n>mut_1--' + mut_cds_1 + '\n>mut_2--' + mut_cds_2 + '\n>mut_3--' + mut_cds_3
        self.wt_cds = seq_5p + ref_allele + seq_3p[len(ref_allele) : len(seq_3p)]
        self.mt_cds = seq_5p + alt_allele + seq_3p[len(ref_allele) : len(seq_3p)]
        wt = mutation.cds_to_aa(self.wt_cds)
        mt = mutation.cds_to_aa(self.mt_cds)

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

    # function to iterate over all the the neopeptide predictions made in the entire MAF and identify
    # which neopeptides are generated by this mutation object
    def match_with_neopeptides(self, all_neopeptides):
        for np in all_neopeptides:
            # make sure the neopeptide is not a peptide fragment of the wild-type protein
            if np.icore in self.mt_altered_aa and np.icore not in self.wt_aa:
                self.predicted_neopeptides.add_neopeptide(copy.deepcopy(np))

    # simply prints the original row in the MAF file along with some neoantigen prediction specific
    # appended at the end
    def get_maf_row_to_print(self):
        row = self.maf_row
        row["neo_maf_identifier_key"] = self.identifier_key

        if self.predicted_neopeptides.get_best_binder() is not None:
            best_binder = self.predicted_neopeptides.get_best_binder()

            strong_binders = self.predicted_neopeptides.get_strong_binders()
            weak_binders = self.predicted_neopeptides.get_weak_binders()
            row["neo_best_icore_peptide"] = best_binder.icore
            row["neo_best_score_el"] = best_binder.score_el
            row["neo_best_rank_el"] = best_binder.rank_el
            row["neo_best_score_ba"] = best_binder.score_ba
            row["neo_best_rank_ba"] = best_binder.rank_ba
            row["neo_best_binding_affinity"] = best_binder.binding_affinity
            row["neo_best_binder_class"] = best_binder.binder_class
            row["neo_best_is_in_wt_peptidome"] = best_binder.is_in_wt_peptidome
            row["neo_best_algorithm"] = best_binder.algorithm
            row["neo_best_version"] = best_binder.version
            row["neo_best_hla_allele"] = best_binder.hla_allele
            row["neo_n_peptides_evaluated"] = len(
                self.predicted_neopeptides.get_best_per_icore()
            )
            row["neo_n_strong_binders"] = len(strong_binders)
            row["neo_n_weak_binders"] = len(weak_binders)
        else:
            row["neo_best_icore_peptide"] = ""
            row["neo_best_score_el"] = ""
            row["neo_best_rank_el"] = ""
            row["neo_best_score_ba"] = ""
            row["neo_best_rank_ba"] = ""
            row["neo_best_binding_affinity"] = ""
            row["neo_best_binder_class"] = ""
            row["neo_best_is_in_wt_peptidome"] = ""
            row["neo_best_algorithm"] = ""
            row["neo_best_version"] = ""
            row["neo_best_hla_allele"] = ""
            row["neo_n_peptides_evaluated"] = 0
            row["neo_n_strong_binders"] = 0
            row["neo_n_weak_binders"] = 0
        return row

    # simply prints the original row of the 'combined_output' of neoantigen predictions along with additional columns
    def get_predictions_rows_to_print(self):
        rows = []
        for prediction in self.predicted_neopeptides.neopeptides:
            prediction.row["neo_maf_identifier_key"] = self.identifier_key
            rows.append(prediction.row)
        return rows


if __name__ == "__main__":
    main()
