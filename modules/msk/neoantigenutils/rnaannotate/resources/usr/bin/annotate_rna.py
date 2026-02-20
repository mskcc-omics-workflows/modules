#!/usr/bin/env python3
"""Annotate neoantigen TSV with RNA-seq data from FORTE outputs."""

import argparse
import gzip
import re
import sys

import pandas as pd

VERSION = "1.0.0"


def build_mutation_id(row):
    """Reconstruct mutation_id from MAF columns.

    Matches the format used by generate_input.py:
    - SNP/DNP/TNP: chr_pos_ref_alt
    - DEL: chr_pos_ref_D
    - INS: chr_pos_I_alt
    """
    chrom = str(row["Chromosome"])
    pos = str(row["Start_Position"])
    ref = str(row["Reference_Allele"])
    alt = str(row["Tumor_Seq_Allele2"])
    vtype = str(row["Variant_Type"])

    if vtype == "DEL":
        return f"{chrom}_{pos}_{ref}_D"
    elif vtype == "INS":
        return f"{chrom}_{pos}_I_{alt}"
    else:
        return f"{chrom}_{pos}_{ref}_{alt}"


def extract_rna_columns_from_maf(maf_df):
    """Extract RNA VAF columns from MAF if present.

    Returns DataFrame with mutation_id, rna_alt_count, rna_ref_count, rna_vaf.
    If rna columns are absent, returns DataFrame with NaN values.
    """
    maf_df = maf_df.copy()
    maf_df["mutation_id"] = maf_df.apply(build_mutation_id, axis=1)

    has_rna = "rna_t_alt_count" in maf_df.columns

    result = pd.DataFrame({"mutation_id": maf_df["mutation_id"]})

    if has_rna:
        result["rna_alt_count"] = maf_df["rna_t_alt_count"].values
        result["rna_ref_count"] = maf_df["rna_t_ref_count"].values
        result["rna_vaf"] = maf_df["rna_t_variant_frequency"].values
    else:
        result["rna_alt_count"] = pd.NA
        result["rna_ref_count"] = pd.NA
        result["rna_vaf"] = pd.NA

    return result


def parse_gtf_gene_map(gtf_path):
    """Parse GTF to build transcript_id -> gene_name mapping."""
    tx2gene = {}
    opener = gzip.open if gtf_path.endswith(".gz") else open
    with opener(gtf_path, "rt") as f:
        for line in f:
            if line.startswith("#"):
                continue
            fields = line.strip().split("\t")
            if len(fields) < 9:
                continue
            attrs = fields[8]
            tx_match = re.search(r'transcript_id "([^"]+)"', attrs)
            gene_match = re.search(r'gene_name "([^"]+)"', attrs)
            if tx_match and gene_match:
                tx_id = tx_match.group(1).split(".")[0]
                gene_name = gene_match.group(1)
                tx2gene[tx_id] = gene_name
    return tx2gene


def annotate_expression(abundance_path, gtf_path):
    """Parse Kallisto abundance and map to gene-level TPM.

    Returns DataFrame with Gene, rna_tpm columns.
    Returns None if abundance_path is None.
    """
    if abundance_path is None:
        return None

    abundance = pd.read_csv(abundance_path, sep="\t")
    tx2gene = parse_gtf_gene_map(gtf_path)

    abundance["transcript_id"] = abundance["target_id"].str.split(".").str[0]
    abundance["Gene"] = abundance["transcript_id"].map(tx2gene)

    gene_tpm = (
        abundance.dropna(subset=["Gene"])
        .groupby("Gene")["tpm"]
        .sum()
        .reset_index()
        .rename(columns={"tpm": "rna_tpm"})
    )

    return gene_tpm


def merge_annotations(neo_tsv, rna_vaf_df, expression_df, tpm_threshold=1.0):
    """Merge RNA annotations onto neoantigen TSV.

    Returns annotated DataFrame with rna_tpm, rna_vaf, rna_alt_count,
    rna_ref_count, rna_expressed columns.
    """
    result = neo_tsv.copy()

    if rna_vaf_df is not None:
        result = result.merge(rna_vaf_df, on="mutation_id", how="left")
    else:
        result["rna_alt_count"] = pd.NA
        result["rna_ref_count"] = pd.NA
        result["rna_vaf"] = pd.NA

    if expression_df is not None:
        result = result.merge(expression_df, on="Gene", how="left")
    else:
        result["rna_tpm"] = pd.NA

    tpm_ok = result["rna_tpm"].notna() & (result["rna_tpm"] > tpm_threshold)
    vaf_ok = result["rna_alt_count"].isna() | (result["rna_alt_count"] > 0)
    result["rna_expressed"] = tpm_ok & vaf_ok

    return result


def main():
    parser = argparse.ArgumentParser(description="Annotate neoantigens with RNA data")
    parser.add_argument("--neoantigen_tsv", required=True, help="Neoantigen TSV from convertannotjson")
    parser.add_argument("--maf", required=True, help="Input MAF (may contain rna_* columns)")
    parser.add_argument("--kallisto_abundance", default=None, help="Kallisto abundance.tsv (optional)")
    parser.add_argument("--gtf", default=None, help="GTF file for transcript-to-gene mapping")
    parser.add_argument("--tpm_threshold", type=float, default=1.0, help="TPM threshold for expressed")
    parser.add_argument("--output_annotated", required=True, help="Output annotated TSV")
    parser.add_argument("--output_report", required=True, help="Output detailed RNA report")
    parser.add_argument("-v", "--version", action="version", version=f"%(prog)s {VERSION}")
    args = parser.parse_args()

    neo_tsv = pd.read_csv(args.neoantigen_tsv, sep="\t")
    maf_df = pd.read_csv(args.maf, sep="\t", comment="#")

    rna_vaf_df = extract_rna_columns_from_maf(maf_df)
    expression_df = annotate_expression(args.kallisto_abundance, args.gtf)

    annotated = merge_annotations(neo_tsv, rna_vaf_df, expression_df, args.tpm_threshold)
    annotated.to_csv(args.output_annotated, sep="\t", index=False)

    report_cols = ["mutation_id", "Gene", "rna_tpm", "rna_vaf", "rna_alt_count", "rna_ref_count", "rna_expressed"]
    available_cols = [c for c in report_cols if c in annotated.columns]
    report = annotated[available_cols].drop_duplicates()
    report.to_csv(args.output_report, sep="\t", index=False)


if __name__ == "__main__":
    main()
