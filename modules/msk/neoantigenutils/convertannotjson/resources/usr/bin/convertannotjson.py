#!/usr/bin/env python3

import json
import argparse

VERSION = 1.0

def process_json_file(json_file_path,output_file_path):
    with open(json_file_path, "r") as json_file:
        data = json.load(json_file)

    # Define the TSV header
    tsv_header = ["id", "mutation_id", "Gene", "HLA_gene_id", "sequence", "WT_sequence", "mutated_position", "Kd", "KdWT", "R", "logC", "logA", "quality", "NMD", "git_branch"]

    # Convert JSON to TSV
    tsv_lines = []
    tsv_lines.append("\t".join(tsv_header))

    for neoantigen in data["neoantigens"]:
        tsv_lines.append("\t".join(str(neoantigen.get(field, "")) for field in tsv_header[:-1]))

    tsv_output = "\n".join(tsv_lines)

    # Write the TSV output to a file
    with open(output_file_path, "w") as tsv_file:
        tsv_file.write(tsv_output)

def main():
    parser = argparse.ArgumentParser(description="Process an annotated JSON file and output TSV format.")
    parser.add_argument("--json_file", help="Path to the annotated JSON file")
    parser.add_argument("--output_file", help="Path to the output TSV file")
    parser.add_argument(
        "-v", "--version", action="version", version="v{}".format(VERSION)
    )
    args = parser.parse_args()

    process_json_file(args.json_file,args.output_file)

if __name__ == "__main__":
    main()
