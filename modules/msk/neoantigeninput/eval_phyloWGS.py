import json
import sys
import pandas as pd
import argparse


def main(args):

    def makeChild(subTree):
        newsubtree = {
            "clone_id": int(subTree),
            "clone_mutations": [],
            "children": [],
            "X": 0,
            "x": 0,
            "new_x": 0,
        }

        if str(subTree) in trees[tree]["structure"]:
            for item in trees[tree]["structure"][str(subTree)]:
                if str(subTree) in trees[tree]["structure"]:
                    # recusion occurs here
                    child_dict = makeChild(item)
                    newsubtree["children"].append(child_dict)

            try:
                ssmli = []
                for ssm in treefile["mut_assignments"][str(subTree)]["ssms"]:
                    ssmli.append(chrom_pos_dict[mut_data["ssms"][ssm]["name"]]["id"])
                newsubtree["clone_mutations"] = ssmli
                newsubtree["X"] = trees[tree]["populations"][str(subTree)][
                    "cellular_prevalence"
                ][0]
                newsubtree["x"] = trees[tree]["populations"][str(subTree)][
                    "cellular_prevalence"
                ][1]
                newsubtree["new_x"] = 0.0
            except Exception as e:
                print("Error in adding new subtree. Error not in base case")
                print(e)
                pass

            return newsubtree

        else:
            # Base Case
            # make childrendict and return it
            ssmli = []

            for ssm in treefile["mut_assignments"][str(subTree)]["ssms"]:
                try:
                    ssmli.append(chrom_pos_dict[mut_data["ssms"][ssm]["name"]]["id"])
                except Exception as e:
                    print("Error in appending to mutation list. Error in base case")
                    print(e)
                    pass

            try:
                newsubtree["clone_mutations"] = ssmli
                newsubtree["X"] = trees[tree]["populations"][str(subTree)][
                    "cellular_prevalence"
                ][0]
                newsubtree["x"] = trees[tree]["populations"][str(subTree)][
                    "cellular_prevalence"
                ][1]
                newsubtree["new_x"] = 0.0
            except Exception as e:
                print("Error in adding new subtree. Error in base case")
                print(e)
                pass

            return newsubtree

    with open(args.summary_file, "r") as f:
        # Load the JSON data into a dictionary
        summ_data = json.load(f)

    with open(args.mutation_file, "r") as f:
        # Load the JSON data into a dictionary
        mut_data = json.load(f)

    chrom_pos_dict = {}  # Just used for mapping right now
    mutation_list = []  # Used as the output for mutations
    mutation_dict = (
        {}
    )  # used for matching mutation without the subsititution information from netMHCpan to phyloWGS output

    mafdf = pd.read_csv(args.maf_file, delimiter="\t")

    for index, row in mafdf.iterrows():
        if row["Variant_Type"] == "SNP":
            if row["Variant_Classification"] == "Missense_Mutation":
                missense = 1

            else:
                missense = 0

            if row["Variant_Type"] == "SNP":
                print(
                    str(row["Chromosome"])
                    + "_"
                    + str(row["Start_Position"])
                    + "_"
                    + row["Reference_Allele"]
                    + "_"
                    + row["Tumor_Seq_Allele2"]
                )
                chrom_pos_dict[
                    str(row["Chromosome"])
                    + "_"
                    + str(row["Start_Position"])
                    + "_"
                    + row["Reference_Allele"]
                    + "_"
                    + row["Tumor_Seq_Allele2"]
                ] = {
                    "id": str(row["Chromosome"])
                    + "_"
                    + str(row["Start_Position"])
                    + "_"
                    + row["Reference_Allele"]
                    + "_"
                    + row["Tumor_Seq_Allele2"],
                    "gene": row["Hugo_Symbol"],
                    "missense": missense,
                }

                mutation_list.append(
                    {
                        "id": str(row["Chromosome"])
                        + "_"
                        + str(row["Start_Position"])
                        + "_"
                        + row["Reference_Allele"]
                        + "_"
                        + row["Tumor_Seq_Allele2"],
                        "gene": row["Hugo_Symbol"],
                        "missense": missense,
                    }
                )

                mutation_dict[
                    str(row["Chromosome"]) + "_" + str(row["Start_Position"])
                ] = (
                    str(row["Chromosome"])
                    + "_"
                    + str(row["Start_Position"])
                    + "_"
                    + row["Reference_Allele"]
                    + "_"
                    + row["Tumor_Seq_Allele2"]
                )

            elif row["Variant_Type"] == "DEL":
                chrom_pos_dict[
                    str(row["Chromosome"])
                    + "_"
                    + str(row["Start_Position"])
                    + "_"
                    + row["Reference_Allele"]
                    + "_"
                    + "D"
                ] = {
                    "id": str(row["Chromosome"])
                    + "_"
                    + str(row["Start_Position"])
                    + "_"
                    + row["Reference_Allele"]
                    + "_"
                    + "D",
                    "gene": row["Hugo_Symbol"],
                    "missense": missense,
                }

                mutation_list.append(
                    {
                        "id": str(row["Chromosome"])
                        + "_"
                        + str(row["Start_Position"])
                        + "_"
                        + row["Reference_Allele"]
                        + "_"
                        + "D",
                        "gene": row["Hugo_Symbol"],
                        "missense": missense,
                    }
                )
                mutation_dict[
                    str(row["Chromosome"]) + "_" + str(row["Start_Position"])
                ] = (
                    str(row["Chromosome"])
                    + "_"
                    + str(row["Start_Position"])
                    + "_"
                    + row["Reference_Allele"]
                    + "_"
                    + row["Tumor_Seq_Allele2"]
                )

            elif row["Variant_Type"] == "INS":
                chrom_pos_dict[
                    str(row["Chromosome"])
                    + "_"
                    + str(row["Start_Position"])
                    + "_"
                    + "I"
                    + "_"
                    + row["Tumor_Seq_Allele2"]
                ] = {
                    "id": str(row["Chromosome"])
                    + "_"
                    + str(row["Start_Position"])
                    + "_"
                    + row["Reference_Allele"]
                    + "_"
                    + row["Tumor_Seq_Allele2"],
                    "gene": row["Hugo_Symbol"],
                    "missense": missense,
                }

                mutation_list.append(
                    {
                        "id": str(row["Chromosome"])
                        + "_"
                        + str(row["Start_Position"])
                        + "_"
                        + "I"
                        + "_"
                        + row["Tumor_Seq_Allele2"],
                        "gene": row["Hugo_Symbol"],
                        "missense": missense,
                    }
                )
                mutation_dict[
                    str(row["Chromosome"]) + "_" + str(row["Start_Position"])
                ] = (
                    str(row["Chromosome"])
                    + "_"
                    + str(row["Start_Position"])
                    + "_"
                    + row["Reference_Allele"]
                    + "_"
                    + row["Tumor_Seq_Allele2"]
                )

    outer_dict = {"id": args.id, "sample_trees": []}

    trees = summ_data["trees"]

    for tree in trees:

        inner_sample_tree_dict = {"topology": [], "score": trees[tree]["llh"]}

        print(tree)

        with open("./" + args.tree_directory + "/" + str(tree) + ".json", "r") as f:
            # Load the JSON data into a dictionary
            treefile = json.load(f)

        bigtree = makeChild(tree)

        inner_sample_tree_dict["topology"] = bigtree

        outer_dict["sample_trees"].append(inner_sample_tree_dict)

    outer_dict["mutations"] = mutation_list

    # TODO format HLA_gene input data, depending on format inputted.  They should look like this A*02:01
    # this will be setup for polysolver winners output
    def convert_polysolver_hla(polyHLA):
        allele = polyHLA[4]
        shortHLA = polyHLA.split("_")[2:4]
        return allele.upper() + "*" + shortHLA[0] + ":" + shortHLA[1]

    HLA_gene_li = []
    with open(args.HLA_genes, "r") as f:
        for line in f:
            line = line.split("\t")

            HLA_gene_li.append(convert_polysolver_hla(line[1]))
            HLA_gene_li.append(convert_polysolver_hla(line[2]))

    outer_dict["HLA_genes"] = HLA_gene_li

    if args.patient_data_file:
        # TODO format optional input data, depending on format of inputted file.  I was imagining a tsv, but can be anything
        status = 0
        OS_tmp = 0
        PFS = 0

        outer_dict["status"] = status
        outer_dict["OS"] = OS_tmp
        outer_dict["PFS"] = PFS
    else:
        outer_dict["status"] = 0
        outer_dict["OS"] = 0
        outer_dict["PFS"] = 0

    outer_dict["id"] = args.id
    outer_dict["patient"] = args.patient_id
    outer_dict["cohort"] = args.cohort

    outer_dict["neoantigens"] = []

    netMHCpan_out_reformat(args.netMHCpan_MUT_input, True)
    netMHCpan_out_reformat(args.netMHCpan_WT_input, False)

    print(mutation_dict)

    neoantigen_mut_in = pd.read_csv("netmHCpanoutput.MUT.tsv", sep="\t")
    neoantigen_WT_in = pd.read_csv("netmHCpanoutput.WT.tsv", sep="\t")

    def find_first_difference_index(str1, str2):
        min_length = min(len(str1), len(str2))
        for i in range(min_length):
            if str1[i] != str2[i]:
                return i
        # If no difference found in the common length, return the length of the shorter string
        return min_length

    for (index_mut, row_mut), (index_WT, row_WT) in zip(
        neoantigen_mut_in.iterrows(), neoantigen_WT_in.iterrows()
    ):
        # affinity cutoff... should it be variable configable?
        if row_mut["affinity"] < 500:

            mut_pos = (
                find_first_difference_index(row_mut["peptide"], row_WT["peptide"]) + 1
            )
            peplen = len(row_mut["peptide"])
            if row_mut["Identity"][-1] == "_":
                row_mut["Identity"][:-1]

            neo_dict = {
                "id": row_mut["Identity"]
                + "_"
                + str(peplen)
                + "_"
                + row_mut["MHC"].split("-")[1].replace(":", "").replace("*", ""),
                "mutation_id": row_mut["Identity"],
                "HLA_gene_id": row_mut["MHC"],
                "sequence": row_mut["peptide"],
                "WT_sequence": row_WT["peptide"],
                "mutated_position": mut_pos,
                "Kd": float(row_mut["affinity"]),
                "KdWT": float(row_WT["affinity"]),
            }
            outer_dict["neoantigens"].append(neo_dict)
        # print(neo_dict)

    outjson = args.patient_id + "_" + args.id + "_" + ".json"
    with open(outjson, "w") as tstout:
        json.dump(outer_dict, tstout, indent=1)
        # tstout.write(json.dumps(outer_dict))


def netMHCpan_out_reformat(netMHCpanoutput, mut):
    file_li = []
    if mut == True:
        outfilename = "netmHCpanoutput.MUT.tsv"
    else:
        outfilename = "netmHCpanoutput.WT.tsv"
    with open(netMHCpanoutput, "r") as file:
        # data = file.read()
        for line in file:
            # Remove leading whitespace
            line = line.lstrip()
            print(line)
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

    with open(outfilename, "w") as file:
        file.writelines(
            "pos\tMHC\tpeptide\tcore\tOF\tGp\tGl\tIp\tIl\ticore\tIdentity\tscore_el\trank_el\tscore_ba\trank_ba\taffinity\n"
        )
        for item in file_li:
            file.writelines(item)
            file.writelines("\n")


def parse_args():
    parser = argparse.ArgumentParser(description="Process input files and parameters")
    parser.add_argument("--maf_file", required=True, help="Path to the MAF file")
    parser.add_argument(
        "--summary_file", required=True, help="Path to the summary file"
    )
    parser.add_argument(
        "--mutation_file", required=True, help="Path to the mutation file"
    )
    parser.add_argument(
        "--tree_directory",
        required=True,
        help="Path to the tree directory containing json files",
    )
    parser.add_argument("--id", required=True, help="ID")
    parser.add_argument("--patient_id", required=True, help="Patient ID")
    parser.add_argument("--cohort", required=True, help="Cohort")
    parser.add_argument(
        "--HLA_genes", required=True, help="Path to the file containing HLA genes"
    )
    parser.add_argument(
        "--netMHCpan_MUT_input",
        required=True,
        help="Path to the file containing MUT netmhcpan results",
    )
    parser.add_argument(
        "--netMHCpan_WT_input",
        required=True,
        help="Path to the file containing WT netmhcpan results",
    )

    parser.add_argument(
        "--patient_data_file",
        help="Path to the optional file containing status, overall survival, and PFS",
    )
    parser.add_argument("-v", "--version", action="version", version="%(prog)s 1.0")

    return parser.parse_args()


def print_help():
    print(
        "Usage: python eval_phyloWGS.py --maf_file <maf_file> --summary_file <summary_file> --mutation_file <mutation_file> --tree_directory <tree_directory> --id <id> --patient_id <patient_id> --cohort <cohort> --HLA_genes <HLA_genes> [--patient_data_file <patient_data_file>]"
    )
    print(
        "Example: python eval_phyloWGS.py --maf_file file.maf --summary_file summary_file.txt --mutation_file mutation_file.txt --tree_directory ./tree_directory/ --id id --patient_id patient_id --cohort cohort --HLA_genes HLA_genes_file --patient_data_file optional_file.txt"
    )
    print("Arguments:")
    print("  --maf_file\t\tPath to the MAF file")
    print("  --summary_file\tPath to the summary file from PhyloWGS")
    print("  --mutation_file\tPath to the mutation file from PhyloWGS")
    print("  --id\t\t\tID")
    print("  --patient_id\t\tPatient ID")
    print("  --cohort\t\tCohort")
    print("  --HLA_genes\t\tPath to the file containing HLA genes")
    print(
        "  --netMHCpan_MUT_input\t\tPath to the file containing  MUT netmhcpan results"
    )
    print("  --netMHCpan_WT_input\t\tPath to the file containing  WT netmhcpan results")
    print(
        "  --patient_data_file\t(Optional) Path to the optional file containing status, overall survival, and PFS"
    )


if __name__ == "__main__":
    args = parse_args()
    print("MAF File:", args.maf_file)
    print("Summary File:", args.summary_file)
    print("Mutation File:", args.mutation_file)
    print("Tree directory:", args.tree_directory)
    print("ID:", args.id)
    print("Patient ID:", args.patient_id)
    print("Cohort:", args.cohort)
    print("HLA Genes File:", args.HLA_genes)
    print("netMHCpan Files:", args.netMHCpan_MUT_input, args.netMHCpan_WT_input)
    if args.patient_data_file:
        print("patient_data_file File:", args.patient_data_file)

    main(args)
