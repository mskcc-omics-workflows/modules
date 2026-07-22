#!/usr/bin/env python3

import os
import sys
import argparse
import traceback
import pandas as pd
import logging
from mutalyzer.normalizer import normalize

VERSION = 1.3

# Effect terms that can yield a neoantigen, matched case-insensitively as
# substrings of the effect field. Genome Nexus' ``Additional_Transcripts``
# column reports MAF ``Variant_Classification`` values (e.g. Missense_Mutation),
# so those are covered here; the VEP consequence terms are kept as well so the
# check also works if fed a raw VEP consequence.
NEOANTIGEN_CAPABLE_CONSEQUENCES = (
    # VEP consequence terms
    "missense",
    "inframe_insertion",
    "inframe_deletion",
    "frameshift",
    "stop_gained",
    "stop_lost",
    "start_lost",
    "protein_altering",
    "splice_acceptor",
    "splice_donor",
    # MAF Variant_Classification terms (Genome Nexus Additional_Transcripts)
    "in_frame",
    "frame_shift",
    "nonsense",
    "nonstop",
    "translation_start_site",
    "splice_site",
)

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
        "--multi_transcript",
        action="store_true",
        help="Also generate neoantigen peptides for the alternate (non-annotated) "
        "transcripts listed in the MAF Additional_Transcripts column "
        "(Genome Nexus -m extended).",
    )
    optional_arguments.add_argument(
        "-v", "--version", action="version", version="%(prog)s {}".format(VERSION)
    )

    args = parser.parse_args()

    maf_file = str(args.maf_file)
    output_dir = str(args.output_dir)
    sample_id = str(args.sample_id)
    multi_transcript = bool(args.multi_transcript)
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

        # Multi-transcript accumulators (only populated/written when --multi_transcript).
        # surrogate_by_seq maps a net-new alt MUT window sequence to its integer
        # surrogate label (global dedup across the sample), so the same peptide is
        # only scored once by netMHC. map_rows collects one row per
        # (mutation, qualifying transcript) for the transcript_map.tsv side-car.
        surrogate_by_seq = {}
        surrogate_wt = {}
        map_rows = []
        alt_memo = {}

        for _, row in maf_df.iterrows():

            n_muts += 1

            mut = mutation(row)

            if mut.is_non_syn():
                n_non_syn_muts += 1

            response = mut.generate_translated_sequences(max(peptide_lengths))

            if response == -1:
                n_missing_tx_id += 1

            if len(mut.mt_altered_aa) > 5:
                out_fa.write(">" + mut.identifier_key + "_M\n")
                out_fa.write(mut.mt_altered_aa + "\n")
                out_WT_fa.write(">" + mut.identifier_key + "_W\n")
                out_WT_fa.write(mut.wt_altered_aa + "\n")

                ### write out WT/MT CDS + AA for debugging purposes
                debug_out_fa.write(">" + mut.identifier_key + "_M\n")
                debug_out_fa.write("mt_altered_aa: " + mut.mt_altered_aa + "\n")
                debug_out_fa.write("wt_full_aa: " + mut.wt_aa + "\n")
                debug_out_fa.write("mt_full_aa: " + mut.mt_aa + "\n")
            mutations.append(mut)

            if multi_transcript:
                process_alt_transcripts(
                    mut,
                    max(peptide_lengths),
                    surrogate_by_seq,
                    surrogate_wt,
                    map_rows,
                    alt_memo,
                )

        out_fa.close()
        out_WT_fa.close()
        debug_out_fa.close()

        if multi_transcript:
            write_multi_transcript_outputs(
                sample_path_pfx, surrogate_by_seq, surrogate_wt, map_rows
            )

        logger.info("\tMAF mutations summary")
        logger.info("\t\t# mutations: " + str(n_muts))
        logger.info(
            "\t\t# non-syn: "
            + str(n_non_syn_muts)
            + " (# missing from cache: "
            + str(n_missing_tx_id)
            + ")"
        )
        if multi_transcript:
            logger.info("\tMulti-transcript summary")
            logger.info("\t\t# transcript_map rows: " + str(len(map_rows)))
            logger.info(
                "\t\t# net-new alt peptides (surrogates): "
                + str(len(surrogate_by_seq))
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


#######################
### Multi-transcript helpers (only exercised when --multi_transcript)
#######################


def parse_additional_transcripts(additional_transcripts):
    """Parse the Genome Nexus ``Additional_Transcripts`` MAF column.

    Genome Nexus (``-m extended``) emits this column as a ``;``-separated list of
    the *alternate* transcripts for a variant -- the canonical transcript is NOT
    included here (it lives in the main MAF columns). Each entry is a
    ``,``-separated record with the fields, in order,
    ``Transcript_ID,Hugo_Symbol,HGVSp_Short,HGVSc,Variant_Classification`` (e.g.
    ``ENST00000379389,ISG15,p.Ile36=,c.106A>G,Silent``).

    The returned tuple keeps the shape the rest of this module expects,
    ``(symbol, consequence, hgvsp_short, transcript_id, refseq, hgvsc)``, where
    ``consequence`` is the MAF ``Variant_Classification`` and ``refseq`` is ``""``
    (Genome Nexus does not emit a per-transcript RefSeq in this column). HGVSc is
    taken from its fixed position but falls back to a ``c.``/``n.`` prefix search
    so a future column-order change does not silently drop it.

    Trailing/empty entries and short/malformed records are tolerated and skipped.
    Records without a transcript id are skipped.
    """
    effects = []
    if additional_transcripts is None or pd.isnull(additional_transcripts):
        return effects
    for chunk in str(additional_transcripts).split(";"):
        chunk = chunk.strip()
        if not chunk:
            continue
        fields = [f.strip() for f in chunk.split(",")]
        # need at least Transcript_ID,Hugo_Symbol,HGVSp_Short,HGVSc
        if len(fields) < 4:
            continue
        transcript_id = fields[0]
        symbol = fields[1]
        hgvsp_short = fields[2]
        # HGVSc is field 3, but locate it by its "c."/"n." prefix if that slot
        # does not look like an HGVSc (robust to column-order changes).
        hgvsc = fields[3] if fields[3].startswith(("c.", "n.")) else next(
            (f for f in fields if f.startswith(("c.", "n."))),
            "",
        )
        consequence = fields[4] if len(fields) >= 5 else ""
        refseq = ""
        if not transcript_id:
            continue
        effects.append(
            (symbol, consequence, hgvsp_short, transcript_id, refseq, hgvsc)
        )
    return effects


def is_neoantigen_capable(consequence):
    """True if the VEP consequence can yield a neoantigen (case-insensitive)."""
    if not consequence:
        return False
    c = consequence.lower()
    return any(term in c for term in NEOANTIGEN_CAPABLE_CONSEQUENCES)


def normalize_to_windows(transcript_id, hgvsc, pad_len):
    """Build the WT/MT peptide windows for ``transcript_id:hgvsc``.

    Uses the per-transcript HGVSc emitted by Genome Nexus (in
    ``Additional_Transcripts``) and the SAME Mutalyzer ``normalize`` call as the
    annotated single-transcript
    path -- there is no genomic crossmapping, so this is robust for
    missense/indel/frameshift alike and needs no genomic reference in the cache.

    Returns ``(wt_window, mt_window)``. On any failure (missing/invalid HGVSc,
    Mutalyzer error, missing protein, exception) a warning is logged and
    ``(None, None)`` is returned so the caller skips the transcript; this
    function never raises.
    """
    if not hgvsc or "c" not in str(hgvsc):
        return None, None
    try:
        response = normalize(f"{transcript_id}:{hgvsc}")
        if "errors" in response:
            error_obj = response["errors"][0]
            logger.warning(
                "Mutalyzer error for alt transcript "
                + f"{transcript_id}:{hgvsc}: "
                + str(error_obj.get("code", ""))
                + ", "
                + str(error_obj.get("details", ""))
            )
            return None, None
        protein = response.get("protein")
        if not protein or "predicted" not in protein or "reference" not in protein:
            logger.warning(
                "No protein prediction for alt transcript "
                + f"{transcript_id}:{hgvsc}"
            )
            return None, None
        return extract_altered_windows(
            protein["reference"], protein["predicted"], pad_len
        )
    except Exception:
        logger.warning(
            "Failed to build peptide for alt transcript "
            + f"{transcript_id}:{hgvsc}; skipping\n"
            + traceback.format_exc()
        )
        return None, None


def process_alt_transcripts(
    mut, pad_len, surrogate_by_seq, surrogate_wt, map_rows, alt_memo
):
    """Enumerate, build and collapse alternate transcripts for one mutation.

    Reads the mutation's ``Additional_Transcripts`` column, keeps only
    neoantigen-capable consequences, builds each surviving alt transcript's peptide from its
    Genome-Nexus-supplied ``transcript:HGVSc`` via the same Mutalyzer
    ``normalize`` call as the annotated path (memoized by
    ``(transcript_id, hgvsc)``), compares each alt MUT window to the annotated
    MUT window (``same_as_annotated``), assigns surrogate integers to net-new MUT
    windows, and appends one ``map_rows`` entry per (mutation, qualifying
    transcript).

    The annotated transcript is recorded in the map (``is_annotated=True``,
    ``same_as_annotated=True``, blank surrogate) but is NOT re-built -- its
    window comes from the already-computed primary path.
    """
    row = mut.maf_row
    annotated_transcript = str(row["Transcript_ID"])
    annotated_mut_window = mut.mt_altered_aa

    mutation_id = (
        str(row["Chromosome"])
        + "_"
        + str(row["Start_Position"])
        + "_"
        + str(row["Reference_Allele"])
        + "_"
        + str(row["Tumor_Seq_Allele2"])
    )

    # Always record the annotated (canonical) transcript. Genome Nexus'
    # Additional_Transcripts column lists only the *alternate* transcripts, so
    # the canonical one is taken from the main MAF columns here rather than being
    # found among the parsed alternates. Its window is the already-computed
    # primary window, so it is not re-built.
    if annotated_transcript and annotated_transcript.lower() != "nan":
        map_rows.append(
            {
                "mutation_id": mutation_id,
                "identifier_key": mut.identifier_key,
                "transcript_id": annotated_transcript,
                "refseq": row.get("RefSeq", "") if hasattr(row, "get") else "",
                "is_annotated": True,
                "consequence": (
                    row.get("Variant_Classification", "")
                    if hasattr(row, "get")
                    else ""
                ),
                "hgvsp_short": (
                    row.get("HGVSp_Short", "") if hasattr(row, "get") else ""
                ),
                "same_as_annotated": True,
                "surrogate_id": "",
            }
        )

    additional_transcripts = (
        row.get("Additional_Transcripts")
        if hasattr(row, "get")
        else row["Additional_Transcripts"]
    )
    effects = parse_additional_transcripts(additional_transcripts)
    if not effects:
        logger.warning(
            "multi_transcript: no alternate transcripts in Additional_Transcripts "
            + "for "
            + mutation_id
            + "; using single-transcript behavior for this mutation"
        )
        return

    for symbol, consequence, hgvsp_short, transcript_id, refseq, hgvsc in effects:
        # Genome Nexus excludes the canonical transcript from this column, but
        # skip it defensively if it ever appears (already recorded above) so the
        # map never carries a duplicate annotated row.
        if transcript_id == annotated_transcript:
            continue

        if not is_neoantigen_capable(consequence):
            continue

        if not hgvsc:
            logger.warning(
                "multi_transcript: no HGVSc in Additional_Transcripts for alt transcript "
                + transcript_id
                + " of "
                + mutation_id
                + "; skipping (Genome Nexus must emit per-transcript HGVSc)"
            )
            continue

        memo_key = (transcript_id, hgvsc)
        if memo_key in alt_memo:
            wt_window, mt_window = alt_memo[memo_key]
        else:
            wt_window, mt_window = normalize_to_windows(
                transcript_id, hgvsc, pad_len
            )
            alt_memo[memo_key] = (wt_window, mt_window)

        if wt_window is None or mt_window is None:
            continue

        # Skip windows too short to be peptides (mirrors the primary path's >5 gate).
        if len(mt_window) <= 5:
            continue

        # An alt transcript whose MUT window equals its own WT window is silent at
        # that transcript -> not a neoantigen; skip it entirely.
        if mt_window == wt_window:
            continue

        same_as_annotated = mt_window == annotated_mut_window

        if same_as_annotated:
            surrogate_id = ""
        else:
            # Net-new MUT peptide. Dedup by (mutation, sequence) so a surrogate
            # never spans two different mutations (which would mis-map downstream);
            # identical net-new peptides across transcripts of the SAME mutation
            # still share one surrogate and collapse into a single entry.
            surr_key = (mutation_id, mt_window)
            surrogate_id = surrogate_by_seq.get(surr_key)
            if surrogate_id is None:
                surrogate_id = str(len(surrogate_by_seq) + 1)
                surrogate_by_seq[surr_key] = surrogate_id
                # Representative WT window for this surrogate (first one wins).
                surrogate_wt[surrogate_id] = wt_window

        map_rows.append(
            {
                "mutation_id": mutation_id,
                "identifier_key": mut.identifier_key,
                "transcript_id": transcript_id,
                "refseq": refseq,
                "is_annotated": False,
                "consequence": consequence,
                "hgvsp_short": hgvsp_short,
                "same_as_annotated": same_as_annotated,
                "surrogate_id": surrogate_id,
            }
        )


def write_multi_transcript_outputs(
    sample_path_pfx, surrogate_by_seq, surrogate_wt, map_rows
):
    """Write the alt MUT/WT FASTAs and the transcript_map.tsv side-car.

    - ``*.altMUT.fa``: one record per net-new MUT peptide, header
      ``>`` + surrogate integer.
    - ``*.altWT.fa``: the representative WT window per surrogate,
      header ``>`` + surrogate integer.
    - ``*.transcript_map.tsv``: tab-separated, with header, one row per
      (mutation, qualifying transcript).

    The alt FASTA names deliberately avoid the ``.MUT.sequences.fa`` /
    ``.WT.sequences.fa`` suffixes so the primary mut_fasta/wt_fasta output globs
    do not also capture them.
    """
    alt_mut_fa = sample_path_pfx + ".altMUT.fa"
    alt_wt_fa = sample_path_pfx + ".altWT.fa"
    transcript_map_tsv = sample_path_pfx + ".transcript_map.tsv"

    # Only write the alt FASTAs when there is at least one net-new peptide, so an
    # empty file is never handed to netMHC (which errors on empty input). The
    # transcript_map is always written so corroboration annotation still works.
    if surrogate_by_seq:
        with open(alt_mut_fa, "w") as out_alt_mut, open(alt_wt_fa, "w") as out_alt_wt:
            # Emit in surrogate order for deterministic output.
            for surr_key, surrogate_id in sorted(
                surrogate_by_seq.items(), key=lambda kv: int(kv[1])
            ):
                seq = surr_key[1]
                out_alt_mut.write(">" + surrogate_id + "\n")
                out_alt_mut.write(seq + "\n")
                out_alt_wt.write(">" + surrogate_id + "\n")
                out_alt_wt.write(surrogate_wt[surrogate_id] + "\n")

    map_columns = [
        "mutation_id",
        "identifier_key",
        "transcript_id",
        "refseq",
        "is_annotated",
        "consequence",
        "hgvsp_short",
        "same_as_annotated",
        "surrogate_id",
    ]
    with open(transcript_map_tsv, "w") as out_map:
        out_map.write("\t".join(map_columns) + "\n")
        for r in map_rows:
            out_map.write(
                "\t".join(
                    [
                        str(r["mutation_id"]),
                        str(r["identifier_key"]),
                        str(r["transcript_id"]),
                        str(r["refseq"]),
                        "True" if r["is_annotated"] else "False",
                        str(r["consequence"]),
                        str(r["hgvsp_short"]),
                        "True" if r["same_as_annotated"] else "False",
                        str(r["surrogate_id"]),
                    ]
                )
                + "\n"
            )


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
            "nonsense_mutation": "X",
            "silent_mutation": "S",
            "silent": "S",
            "frame_shift_ins": "Fi",
            "frame_shift_del": "Fd",
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

        self.wt_aa = wt
        self.mt_aa = mt

        self.wt_altered_aa, self.mt_altered_aa = extract_altered_windows(
            wt, mt, pad_len
        )


# function that, given full WT and MT protein sequences, extracts the ± window
# peptides around the altered region. Shared by the annotated path and the
# multi-transcript alt path so both apply identical windowing.
def extract_altered_windows(wt, mt, pad_len):
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

    wt_altered_aa = wt[max(0, wt_start - pad_len + 1) : min(len(wt), wt_end + pad_len - 1)]
    mt_altered_aa = mt[max(0, mt_start - pad_len + 1) : min(len(mt), mt_end + pad_len - 1)]

    return wt_altered_aa, mt_altered_aa


if __name__ == "__main__":
    main()
