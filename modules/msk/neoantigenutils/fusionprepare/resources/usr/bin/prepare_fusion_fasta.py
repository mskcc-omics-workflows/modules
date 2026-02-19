#!/usr/bin/env python3
"""Convert AGFusion output to pipeline-compatible FASTA format."""

import argparse
import os

VERSION = "1.0.0"


def parse_agfusion_dir(agfusion_dir):
    """Parse AGFusion output directory for fusion protein sequences.

    AGFusion creates subdirectories per fusion event, each containing
    *_protein.fa files with fusion protein sequences.
    """
    fusions = []
    for entry in sorted(os.listdir(agfusion_dir)):
        subdir = os.path.join(agfusion_dir, entry)
        if not os.path.isdir(subdir):
            continue
        gene_pair = entry
        for fname in sorted(os.listdir(subdir)):
            if fname.endswith("_protein.fa"):
                fpath = os.path.join(subdir, fname)
                sequences = read_fasta(fpath)
                for seq_id, seq in sequences:
                    fusions.append({
                        "gene_pair": gene_pair,
                        "transcript_pair": seq_id,
                        "sequence": seq,
                    })
    return fusions


def read_fasta(path):
    """Read FASTA file, return list of (header, sequence) tuples."""
    sequences = []
    current_header = None
    current_seq = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if line.startswith(">"):
                if current_header:
                    sequences.append((current_header, "".join(current_seq)))
                current_header = line[1:]
                current_seq = []
            elif line:
                current_seq.append(line)
    if current_header:
        sequences.append((current_header, "".join(current_seq)))
    return sequences


def extract_junction_peptides(fusion_seq, junction_pos, peptide_lengths=None):
    """Extract peptide windows spanning the fusion junction.

    For each peptide length, slide a window across the junction point.
    Each peptide must include at least 1 AA from each fusion partner.
    """
    if peptide_lengths is None:
        peptide_lengths = [9, 10, 11]
    peptides = []
    for plen in peptide_lengths:
        if len(fusion_seq) < plen:
            continue
        start_min = max(0, junction_pos - plen + 1)
        start_max = min(junction_pos, len(fusion_seq) - plen)
        for start in range(start_min, start_max + 1):
            pep = fusion_seq[start:start + plen]
            if len(pep) == plen:
                peptides.append(pep)
    return peptides


def infer_junction_position(fusion_seq, five_prime_len=None):
    """Infer junction position from AGFusion sequence.

    AGFusion marks the junction with '*' in some outputs.
    If not present, use five_prime_len if provided, else midpoint.
    """
    if "*" in fusion_seq:
        return fusion_seq.index("*")
    if five_prime_len is not None:
        return five_prime_len
    return len(fusion_seq) // 2


def write_fasta_pair(peptides, mut_path, wt_path):
    """Write MUT and WT FASTA files for pipeline compatibility."""
    with open(mut_path, "w") as mut_f, open(wt_path, "w") as wt_f:
        for pep in peptides:
            mut_f.write(f">{pep['id']}_M\n{pep['mut_seq']}\n")
            wt_f.write(f">{pep['id']}_W\n{pep['wt_seq']}\n")


def main():
    parser = argparse.ArgumentParser(description="Prepare fusion FASTAs for neoantigen pipeline")
    parser.add_argument("--agfusion_dir", required=True, help="AGFusion output directory")
    parser.add_argument("--output_prefix", required=True, help="Output file prefix")
    parser.add_argument("--peptide_lengths", default="9,10,11", help="Comma-separated peptide lengths")
    parser.add_argument("-v", "--version", action="version", version=f"%(prog)s {VERSION}")
    args = parser.parse_args()

    peptide_lengths = [int(x) for x in args.peptide_lengths.split(",")]
    fusions = parse_agfusion_dir(args.agfusion_dir)

    all_peptides = []
    pep_counter = 0
    for fusion in fusions:
        seq = fusion["sequence"].replace("*", "")
        junction = infer_junction_position(fusion["sequence"])
        junction_peps = extract_junction_peptides(seq, junction, peptide_lengths)
        for pep in junction_peps:
            pep_counter += 1
            all_peptides.append({
                "id": f"{fusion['gene_pair']}_{pep_counter}",
                "mut_seq": pep,
                "wt_seq": pep,
            })

    mut_path = f"{args.output_prefix}.SV.MUT.fa"
    wt_path = f"{args.output_prefix}.SV.WT.fa"
    write_fasta_pair(all_peptides, mut_path, wt_path)


if __name__ == "__main__":
    main()
