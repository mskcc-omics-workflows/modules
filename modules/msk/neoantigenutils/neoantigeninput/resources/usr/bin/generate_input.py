#!/usr/bin/env python3

import json
import pandas as pd
import argparse
import os
import Bio
from Bio import pairwise2
from Bio.pairwise2 import format_alignment
import numpy as np
from pyensembl.genome import Genome
from pyensembl import EnsemblRelease

VERSION = 1.9


def main(args):

    def makeChild(subTree, start):
        if start:
            subTree = 0

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

                child_dict = makeChild(item, False)

                newsubtree["children"].append(child_dict)

            try:
                ssmli = []
                if start:
                    pass
                else:
                    for ssm in treefile["mut_assignments"][str(subTree)]["ssms"]:
                        ssmli.append(
                            chrom_pos_dict[mut_data["ssms"][ssm]["name"]]["id"]
                        )
                newsubtree["clone_mutations"] = ssmli
                newsubtree["X"] = trees[tree]["populations"][str(subTree)][
                    "cellular_prevalence"
                ][0]
                newsubtree["x"] = trees[tree]["populations"][str(subTree)][
                    "cellular_prevalence"
                ][0]
                newsubtree["new_x"] = 0.0
            except Exception as e:
                print("Error in adding new subtree. Error not in base case**")
                print(subTree)
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
                    print(
                        "Error in appending to mutation list. Error in base case appending ssm to ssmli"
                    )
                    print(e)
                    # print(str(subTree))
                    pass

            try:
                newsubtree["clone_mutations"] = ssmli
                newsubtree["X"] = trees[tree]["populations"][str(subTree)][
                    "cellular_prevalence"
                ][0]
                newsubtree["x"] = trees[tree]["populations"][str(subTree)][
                    "cellular_prevalence"
                ][0]
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
    )  # Used for matching mutation without the subsititution information from netMHCpan to phyloWGS output
    gene_dict = {}

    mafdf = pd.read_csv(args.maf_file, delimiter="\t")

    for index, row in mafdf.iterrows():
        if (
            # We
            row["Variant_Type"] == "SNP"
            or row["Variant_Type"] == "DEL"
            or row["Variant_Type"] == "INS"
            or row["Variant_Type"] == "DNP"
            or row["Variant_Type"] == "TNP"
        ):
            if row["Variant_Classification"] == "Missense_Mutation":
                missense = 1

            else:
                missense = 0
                
            
            if (
                row["Variant_Type"] == "SNP"
                or row["Variant_Type"] == "DNP"
                or row["Variant_Type"] == "TNP"
            ):
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
                    "transcript": row["Feature"]
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

                mutation_dict[makeID(row)] = (
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
                    + str(row["Start_Position"] - 1)
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
                    "transcript": row["Feature"]
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
                mutation_dict[makeID(row)] = (
                    str(row["Chromosome"])
                    + "_"
                    + str(row["Start_Position"] - 1)
                    + "_"
                    + row["Reference_Allele"]
                    + "_"
                    + "D"
                )

            elif row["Variant_Type"] == "INS":
                # print(
                #     str(row["Chromosome"])
                #     + "_"
                #     + str(row["Start_Position"])
                #     + "_"
                #     + "I"
                #     + "_"
                #     + row["Tumor_Seq_Allele2"]
                # )
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
                    + "I"
                    + "_"
                    + row["Tumor_Seq_Allele2"],
                    "gene": row["Hugo_Symbol"],
                    "missense": missense,
                    "transcript": row["Feature"]
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
                mutation_dict[makeID(row)] = (
                    str(row["Chromosome"])
                    + "_"
                    + str(row["Start_Position"])
                    + "_"
                    + "I"
                    + "_"
                    + row["Tumor_Seq_Allele2"]
                )

    outer_dict = {"id": args.id, "sample_trees": []}

    trees = summ_data["trees"]

    for tree in trees:

        inner_sample_tree_dict = {"topology": [], "score": trees[tree]["llh"]}
        with open("./" + args.tree_directory + "/" + str(tree) + ".json", "r") as f:
            # Load the JSON data into a dictionary
            treefile = json.load(f)

        bigtree = makeChild(tree, True)

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

    if args.bedpe_file:
        bedpe_list, bedpe_dict = bedpe_load(args.bedpe_file)

    bedpe_match_dict = {}

    ensembl = ensembl_load(args.release, args.gtf_file, args.cdna_file)
    neoantigen_mut_in = pd.read_csv(args.netMHCpan_MUT_input, sep="\t")
    neoantigen_WT_in = pd.read_csv(args.netMHCpan_WT_input, sep="\t")

    def find_first_difference_index(str1, str2):
        min_length = min(len(str1), len(str2))
        for i in range(min_length):
            if str1[i] != str2[i]:
                return i
        # If no difference found in the common length, return the length of the shorter string
        return min_length

    WTdict = {}
    SVWTdict = {}
    for index_WT, row_WT in neoantigen_WT_in.iterrows():
        no_positon_ID = ""
        id = ""
        wtsvid = ""
        row_WT_identity = trim_id(row_WT["Identity"])
        IDsplit = row_WT_identity.split("_")
        print(row_WT_identity)
        if len(IDsplit[0]) < 3:
            # it is from neoSV
            IDsplit = row_WT_identity.split("_")
            wtsvid = (
                IDsplit[0]
                + IDsplit[1][0:7]
                + "_"
                + str(len(row_WT["peptide"]))
                + "_"
                + row_WT["MHC"].split("-")[1].replace(":", "").replace("*", "")
                + "_"
                + str(row_WT["pos"])
            )
            no_positon_ID = (
                IDsplit[0]
                + "_"
                + IDsplit[1][0:7]
                + "_"
                + str(len(row_WT["peptide"]))
                + "_"
                + row_WT["MHC"].split("-")[1].replace(":", "").replace("*", "")
            )
            WTdict[wtsvid] = {
                "affinity": row_WT["affinity"],
                "peptide": row_WT["peptide"],
            }
            id = wtsvid
            if no_positon_ID not in WTdict:
                WTdict[no_positon_ID] = {
                    "peptides": {
                        row_WT["peptide"]: id
                    },  # This is a dict so we can match the peptide with the actual ID later
                    "affinity": row_WT["affinity"],
                }

            else:
                WTdict[no_positon_ID]["peptides"][row_WT["peptide"]] = id

        else:
            id = (
                row_WT_identity[:-2]
                + "_"
                + str(len(row_WT["peptide"]))
                + "_"
                + row_WT["MHC"].split("-")[1].replace(":", "").replace("*", "")
                + "_"
                + str(row_WT["pos"])
            )

            no_positon_ID = (
                row_WT_identity[:-2]
                + "_"
                + str(len(row_WT["peptide"]))
                + "_"
                + row_WT["MHC"].split("-")[1].replace(":", "").replace("*", "")
            )
            WTdict[id] = {"affinity": row_WT["affinity"], "peptide": row_WT["peptide"]}

            # This is used as last resort for the matching.  We will preferentially find the peptide matching in length as well as POS. Worst case we will default to the WT pos 0
            if no_positon_ID not in WTdict:
                WTdict[no_positon_ID] = {
                    "peptides": {
                        row_WT["peptide"]: id
                    },  # This is a dict so we can match the peptide with the ID later
                    "affinity": row_WT["affinity"],
                }

            else:
                WTdict[no_positon_ID]["peptides"][row_WT["peptide"]] = id

    def find_most_similar_string(target, strings):
        max_score = -1
        max_score2 = -2
        most_similar_string = None
        most_similar_string2 = None
        first_AA_same = None
        first_AA_same_score = -1
        len_target = len(target)
        for s in strings:
            if len(s) == len_target:
                alignments = pairwise2.align.globalxx(target, s)
                score = alignments[0][2]  # The third element is the score

                if score > max_score2:

                    if score > max_score:
                        max_score2 = max_score
                        most_similar_string2 = most_similar_string
                        max_score = score
                        most_similar_string = s

                    else:
                        max_score2 = score
                        most_similar_string2 = s

                if target[0] == s[0]:
                    if score > first_AA_same_score:
                        first_AA_same = s
                        first_AA_same_score = score

        return (
            most_similar_string,
            most_similar_string2,
            first_AA_same,
            first_AA_same_score,
            max_score,
        )
    
    NMD_dict = {}
    
    for index_mut, row_mut in neoantigen_mut_in.iterrows():
        row_MUT_identity = trim_id(row_mut["Identity"])
        IDsplit = row_MUT_identity.split("_")
        SV = False
        if row_mut["affinity"] < float(args.kD_cutoff):
            peplen = len(row_mut["peptide"])
            matchfound = False
            frameshift= False
            print(row_MUT_identity)
            if IDsplit[1][0] == "S" and IDsplit[1][1] != "p":
                # If it is a silent mutation.  Silent mutations can either be S or SY. These include intron mutations.  Splices can be Sp
                continue
            if row_MUT_identity.count("_") == 1:
                # its an SV
                SV = True
                WTid = (
                    IDsplit[0]
                    + IDsplit[1][0:8]
                    + "_"
                    + str(len(row_mut["peptide"]))
                    + "_"
                    + row_mut["MHC"].split("-")[1].replace(":", "").replace("*", "")
                    + "_"
                    + str(row_mut["pos"])
                )
                no_positon_ID = (
                    IDsplit[0]
                    + "_"
                    + IDsplit[1][0:8]
                    + "_"
                    + str(len(row_mut["peptide"]))
                    + "_"
                    + row_mut["MHC"].split("-")[1].replace(":", "").replace("*", "")
                )
                # this part makes the dict that matches this to the bedpe
                bedpe_match_dict[row_MUT_identity] = (
                    IDsplit[0] + "_" + IDsplit[1][0:4]
                )
            else:
                # first find match in WT
                WTid = (
                    row_MUT_identity[:-2]
                    + "_"
                    + str(peplen)
                    + "_"
                    + row_mut["MHC"].split("-")[1].replace(":", "").replace("*", "")
                    + "_"
                    + str(row_mut["pos"])
                )
                no_positon_ID = (
                    row_MUT_identity[:-2]
                    + "_"
                    + str(peplen)
                    + "_"
                    + row_mut["MHC"].split("-")[1].replace(":", "").replace("*", "")
                )
            if (
                 ("M" == IDsplit[1][0] and "Sp" not in row_MUT_identity)
                or SV == False
            ):
                # match
                if (
                    (WTid in WTdict)
                    and IDsplit[1][0] != "I"
                    ):
                    #This block takes care of Missense mutations caused by polymorphisims
                    matchfound = True
                    best_pepmatch = WTdict[WTid]["peptide"]
                    
                else:
                    # Here we take care of INDELS and everything else

                    if ("-" in IDsplit[1] or "+" in IDsplit[1]):
                        frameshift = True
                    (
                        best_pepmatch,
                        best_pepmatch2,
                        first_AA_same,
                        first_AA_same_score,
                        match_score,
                    ) = find_most_similar_string(
                        row_mut["peptide"], list(WTdict[no_positon_ID]["peptides"].keys())
                    )
                    if (
                        best_pepmatch == row_mut["peptide"]
                        or best_pepmatch2 == row_mut["peptide"]
                    ):
                        # it seems this can happen where the row_mut is actually the canonical sequence.
                        # In this case we don't want to report the peptide as a neoantigen, its not neo
                        continue

                    elif (
                        best_pepmatch[0] != row_mut["peptide"][0]
                        and best_pepmatch2[0] == row_mut["peptide"][0]
                    ) or (
                        best_pepmatch[-1] != row_mut["peptide"][-1]
                        and best_pepmatch2[-1] == row_mut["peptide"][-1]
                    ):
                        # We should preferentially match the first AA if we can.  Sometimes the pairwise alignment isnt the best at this so we do a little check here.
                        # It will also do this when the last AA of the best match doesnt match but the last A of the second best match does
                        best_pepmatch = best_pepmatch2

                    WTid = WTdict[no_positon_ID]["peptides"][best_pepmatch]
                    matchfound = True

            if matchfound == True and best_pepmatch != row_mut["peptide"]:
                mut_pos = (
                    find_first_difference_index(
                        row_mut["peptide"], best_pepmatch  # WTdict[WTid]["peptide"]
                    )
                    + 1
                )

                
                chrom, pos = mutation_dict[row_mut["Identity"]].split("_")[0:2]
                
                
                
                if frameshift:
                    mut_pos = "Frameshifted peptide"
                    num_windows = len(list(WTdict[no_positon_ID]["peptides"].keys()))
                    num_windows_li = len(list(WTdict[no_positon_ID]["peptides"].values()))
                    # [pep.split(",") for pep in num_windows_li]
                    
                    # print(WTdict[no_positon_ID]["peptides"])
                    print("FRAMESHIFT")
                    
                    if no_positon_ID in NMD_dict:
                        #NMD must only be calculated once per mutation
                        pass
                    else:  
                        split_mutation_dict_ID = mutation_dict[row_MUT_identity].split("_")
                        print(split_mutation_dict_ID)
                        if split_mutation_dict_ID[2] == "I":
                            len_indel = len(split_mutation_dict_ID[3])
                        elif split_mutation_dict_ID[3] == "D":
                            len_indel = 0 - len(split_mutation_dict_ID[2])
                        else:
                            len_indel = 0
                        transcriptID = chrom_pos_dict[mutation_dict[row_MUT_identity]]["transcript"]
                        NMD_dict[no_positon_ID] = determine_NMD(chrom, pos,num_windows,len_indel,ensembl,transcriptID)
                        
                else:
                    NMD_dict[no_positon_ID] = "False"
                    
                if SV:
                    neo_dict = {
                        "id": row_MUT_identity
                        + "_"
                        + str(peplen)
                        + "_"
                        + str(row_mut["pos"])
                        + "_"
                        + row_mut["MHC"].split("-")[1].replace(":", "").replace("*", "")
                        ,
                        "mutation_id": bedpe_dict[
                            bedpe_match_dict[row_MUT_identity]
                        ].id,
                        "Gene": chrom_pos_dict[mutation_dict[row_MUT_identity]]["gene"],
                        "HLA_gene_id": row_mut["MHC"],
                        "sequence": row_mut["peptide"],
                        "WT_sequence": best_pepmatch,  # WTdict[WTid]["peptide"],
                        "mutated_position": mut_pos,
                        "Kd": float(row_mut["affinity"]),
                        "KdWT": float(WTdict[WTid]["affinity"]),
                        "NMD" : NMD_dict[no_positon_ID]
                    }
                else:
                    neo_dict = {
                        "id": row_MUT_identity
                        + "_"
                        + str(peplen)
                        + "_"
                        + str(row_mut["pos"])
                        + "_"
                        + row_mut["MHC"].split("-")[1].replace(":", "").replace("*", ""),
                        "mutation_id": mutation_dict[row_MUT_identity],
                        "Gene": chrom_pos_dict[mutation_dict[row_MUT_identity]]["gene"],
                        "HLA_gene_id": row_mut["MHC"],
                        "sequence": row_mut["peptide"],
                        "WT_sequence": best_pepmatch,  # WTdict[WTid]["peptide"],
                        "mutated_position": mut_pos,
                        "Kd": float(row_mut["affinity"]),
                        "KdWT": float(WTdict[WTid]["affinity"]),
                        "NMD" : NMD_dict[no_positon_ID]
                    }
                outer_dict["neoantigens"].append(neo_dict)

    outjson = args.patient_id + "_" + args.id + "_" + ".json"
    with open(outjson, "w") as tstout:
        json.dump(outer_dict, tstout, indent=1)

# Sometimes the id is set as .*_M_1 and we want to make sure its _M, otherwise it will not match
def trim_id(id_string):
    if "_M_" in id_string:
        return id_string.partition("_M_")[0]+"_M"
    elif "_V_" in id_string:
        return id_string.partition("_V_")[0]+"_V"
    else:
        return id_string


def makeID(maf_row):
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

    position = int(str(maf_row["Start_Position"])[0:2])

    if position < 26:
        encoded_start = ALPHABET[position]
    elif position < 100:
        encoded_start = ALPHABET[position // 4]

    position = int(str(maf_row["Start_Position"])[-2:])

    if position < 26:
        encoded_end = ALPHABET[position]
    elif position < 100:
        encoded_end = ALPHABET[position // 4]

    sum_remaining = sum(int(d) for d in str(maf_row["Start_Position"])[2:-2])

    encoded_position = encoded_start + ALPHABET[sum_remaining % 26] + encoded_end

    if maf_row["Tumor_Seq_Allele2"] == "-":
        # handles deletion
        if len(maf_row["Reference_Allele"]) > 3:
            Allele2code = maf_row["Reference_Allele"][0:3]
        else:
            Allele2code = maf_row["Reference_Allele"]

    elif len(maf_row["Tumor_Seq_Allele2"]) > 1:
        # handles INS and DNP
        if len(maf_row["Tumor_Seq_Allele2"]) > 3:
            Allele2code = maf_row["Tumor_Seq_Allele2"][0:3]
        else:
            Allele2code = maf_row["Tumor_Seq_Allele2"]

    else:
        # SNPs
        Allele2code = maf_row["Tumor_Seq_Allele2"]

    if maf_row["Variant_Classification"].lower() in variant_type_map:
        identifier_key = (
            str(maf_row["Chromosome"])
            + encoded_position
            + "_"
            + variant_type_map[maf_row["Variant_Classification"].lower()]
            + Allele2code
            + "_M"  # This indicates mutated. It is added in the generateMutFasta script as well but not in this function.
        )
    else:
        identifier_key = (
            str(maf_row["Chromosome"])
            + encoded_position
            + "_"
            + "SY"
            + Allele2code
            + "_M"
        )
    return identifier_key


class VariantCallingFormat(object):
    """
    Class for storing SV information in VCF format,
    all components are in string format
    """

    def __init__(self, chrom, pos, ref, alt):
        self.chrom = chrom
        self.pos = pos
        self.ref = ref
        self.alt = alt

    def __str__(self):
        return "%s(chrom = %s, pos = %s, ref = %s, alt = %s)" % (
            self.__class__.__name__,
            self.chrom,
            self.pos,
            self.ref,
            self.alt,
        )

    def __repr__(self):
        return "%s(%s, %s, %s, %s)" % (
            self.__class__.__name__,
            self.chrom,
            self.pos,
            self.ref,
            self.alt,
        )


class BedpeFormat(object):
    """
    Class for storing SV information in BEDPE format,
    all components are in string format
    """

    def __init__(self, chrom1, pos1, strand1, chrom2, pos2, strand2, id):
        self.chrom1 = chrom1
        self.pos1 = pos1
        self.strand1 = strand1
        self.chrom2 = chrom2
        self.pos2 = pos2
        self.strand2 = strand2
        self.id = id

    def __str__(self):
        return (
            "%s(chrom1 = %s, pos1 = %s, strand1 = %s, chrom2 = %s, pos2 = %s, strand2 = %s, id = %s)"
            % (
                self.__class__.__name__,
                self.chrom1,
                self.pos1,
                self.strand1,
                self.chrom2,
                self.pos2,
                self.strand2,
                self.id,
            )
        )

    def __repr__(self):
        return "%s(%s, %s, %s, %s, %s, %s, %s)" % (
            self.__class__.__name__,
            self.chrom1,
            self.pos1,
            self.strand1,
            self.chrom2,
            self.pos2,
            self.strand2,
            self.id,
        )


def bedpe_load(filepath):
    """
    :param filepath: the absolute path of a BEDPE file
    :return: a list of BEDPE objects
    """
    bedpe_list = []
    bedpedict = {}
    filename = os.path.basename(filepath)
    line_num = 0
    print("Loading SVs from {0}.".format(filename))
    with open(filepath, "r") as f:
        header = next(f)
        header = header.rstrip().split("\t")
        for line in f:
            line_num += 1
            tmpline = line.rstrip().split("\t")
            chrom1 = tmpline[header.index("chrom1")].replace("chr", "")
            pos1 = tmpline[header.index("start1")]
            chrom2 = tmpline[header.index("chrom2")].replace("chr", "")
            pos2 = tmpline[header.index("start2")]
            strand1 = tmpline[header.index("strand1")]
            strand2 = tmpline[header.index("strand2")]
            svclass = tmpline[header.index("svclass")]
            sv_bedpe_id = tmpline[header.index("sv_id")]
            custom_id = makeID_bedpe(chrom1, pos1, svclass)
            bedpe = BedpeFormat(
                chrom1, pos1, strand1, chrom2, pos2, strand2, sv_bedpe_id
            )
            bedpe_list.append(bedpe)
            bedpedict[custom_id] = bedpe

    return bedpe_list, bedpedict


def makeID_bedpe(chrom1, pos1, svclass):
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

    position = int(str(pos1)[0:2])

    if position < 26:
        encoded_start = ALPHABET[position]
    elif position < 100:
        encoded_start = ALPHABET[position // 4]

    position = int(str(pos1)[-2:])

    if position < 26:
        encoded_end = ALPHABET[position]
    elif position < 100:
        encoded_end = ALPHABET[position // 4]
    sum_remaining = sum(int(d) for d in str(pos1)[2:-2])

    encoded_position = encoded_start + ALPHABET[sum_remaining % 26] + encoded_end

    identifier_key = (
        str(chrom1)
        + "_"
        + encoded_position
        + "V"  # This indicates structural variant. It is added in the generateMutFasta script as well but not in this function.
    )

    return identifier_key


def get_exon_range(transcript):
    """
    :param transcript: transcript instance in pyensembl
    :return: exon intervals of this transcript
            from 5' to 3', exon 1, exon 2, ...
            [start, end], start < end
    """
    exon_ranges = []
    for exon in transcript.exons:
        exon_ranges.append((exon.start, exon.end))
    return exon_ranges

def get_longest_transcript(transcripts):
    """
    :param transcripts: a list of Transcript(pyensembl) instances
    :return: the longest transcript
    """
    transcripts = sorted(transcripts, key=lambda t: t.end-t.start)
    transcript = transcripts[-1]
    return transcript


def get_transcript(chrom, pos, ensembl, complete=True):
    """
    :param chrom: chromosome with no chr
    :param pos: position of mutation
    :param ensembl: Genome instance in pyensembl
    :param complete: only consider complete transcripts
    :return: firstly return the longest complete transcript,
            if there is no complete transcript and
            complete = False, return the longest transcript
    """
    transcripts = ensembl.transcripts_at_locus(contig=str(chrom), position=int(pos))
    transcripts_comp = [transcript for transcript in transcripts if transcript.complete]
    if transcripts_comp:
        return get_longest_transcript(transcripts_comp)
    else:
        if complete:
            return None
        else:
            if transcripts:
                return get_longest_transcript(transcripts)
            else:
                return None


def ensembl_load(release, gtf_file, cdna_file):
    """
    :param release: the release number in EMSEMBL, could be custom
    :param gtf_file: the path of gtf file if release == custom
    :param cdna_file: the path of cdna file if release == custom
    :param cache_dir: directory for pyensembl downloading
    :return: a Genome class in pyensembl
    """
    # if release != 'custom':
    #     print("doing a new one")
    #     ensembl = EnsemblRelease(int(release))
    #     ensembl.download()
    #     ensembl.index()
        
    # else:
    ensembl = Genome(gtf_path_or_url=gtf_file,
                        transcript_fasta_paths_or_urls=cdna_file,
                        reference_name='User-defined',
                        annotation_name='User-defined')
    ensembl.index()
    return ensembl



def get_exons_from_transcriptID(transcriptid, ensembl, complete=True):
    """
    :param transcriptid: transcriptid from MAF col
    :param ensembl: Genome instance in pyensembl
    :param complete: only consider complete transcripts
    :return: a list of tuples of exon ranges
    """
    
    transcripts= ensembl.exon_ids_of_transcript_id(transcriptid)
    
    exon_ranges = []
    for exonid in transcripts:
        exon = ensembl.exon_by_id(exonid)
        exon_ranges.append((exon.start, exon.end))

    return exon_ranges
    
    
    
def determine_NMD(chrom, pos,num_windows,len_indel, ensembl, transcriptID=None):
    """
    :param chrom: chromosome where alteration takes place
    :param pos: position where alteration takes place
    :pos transcriptID: transcriptID from the MAF.  If it isnt annotated, then use longest transcript
    :num_windows: number of windows created by the peptide
    :len_indel: Length of the indel.  Negative if del, positive if ins
    :param gtf_file: the path of gtf file if release == custom
    :param cdna_file: the path of cdna file if release == custom
    :return: NMD value
    """
    
    if transcriptID == None:
        #do these if maf was not annotated
        transcript = get_transcript(chrom, pos, ensembl)
        exon_ranges = get_exon_range(transcript)
    else:
        exon_ranges = get_exons_from_transcriptID(transcriptID,ensembl)

    NMD = "False"

    pos = int(pos) + 1
    for i in range(0,len(exon_ranges)):
        if pos>=exon_ranges[i][0] and pos<=exon_ranges[i][1]:
            print(f'{pos} in {exon_ranges[i]}, {exon_ranges[i][1]-exon_ranges[i][0]}')
            exon_ranges_dist = [exon_ranges[p][1]-exon_ranges[p][0] for p in range(0,len(exon_ranges))]
            mut_to_stop_dist = (num_windows*3)+len_indel+1 

            for d in range(i,len(exon_ranges_dist)):
                if exon_ranges_dist[d] == exon_ranges_dist[i]:
                    dist = exon_ranges_dist[d] - (exon_ranges[i][1]-pos)
                else:
                    dist = exon_ranges_dist[d]

                if dist - mut_to_stop_dist >= 0: 
                    PTC_exon = exon_ranges[d] 
                    PTC_pos = exon_ranges[d][0] + mut_to_stop_dist
                    break
                elif len(exon_ranges_dist)-1 == d and dist - mut_to_stop_dist < 0:
                    PTC_exon = exon_ranges[d] 
                    PTC_pos = exon_ranges[d][0] + mut_to_stop_dist
                else:
                    mut_to_stop_dist = mut_to_stop_dist - dist

    if PTC_exon == exon_ranges[-1]:
        # "on the last exon"
        NMD = "Last Exon"
        print("on the last exon")
    else: 
        if exon_ranges[0][0] - PTC_pos < 150:
            # less than 150 nt away from the start exon
            NMD = "Start-proximal"
        else:
            if (PTC_exon[1] - PTC_exon[0]) > 407:
                # in a long exon with more than 407 nt
                NMD = "Long Exon"
                print("in a long exon with more than 407 nt")
            else:
                #  it is in the last 50 nt of the penultimate exon
                if PTC_exon == exon_ranges[-2] and (exon_ranges[-2][0] - PTC_pos) < 50 :
                    NMD = "50nt Rule"
                    print("within 50 nt of the penultimate exon")
                else:
                    NMD = "Trigger NMD"

    return NMD
            
    
    
def parse_args():
    parser = argparse.ArgumentParser(description="Process input files and parameters")
    parser.add_argument("--maf_file", required=True, help="Path to the MAF file")
    parser.add_argument("--bedpe_file", required=False, help="Path to the bedpe file")
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
    parser.add_argument('-r', '--release', dest='release', metavar='RELEASE', default='75',
                        help='Which reference (ENSEMBL release) you want to use. Ensembl releases that'
                             'correspond to hg18/NCBI36, hg19/GRCh37, hg38/GRCh38 are 54, 75, 95.'
                             'If your data are from other species(custom), please download the gtf '
                             'file and the cdna file from ENSEMBL website ftp://ftp.ensembl.org/pub'
                             ' and specify them using --gtf-file and --cdna-file.')
    parser.add_argument('-gf', '--gtf-file', dest='gtf_file', metavar='GTF_FILE', default=None,
                        help='GTF file for the reference.')
    parser.add_argument('-cf', '--cdna-file', dest='cdna_file', metavar='CDNA_FILE', default=None,
                        help='cDNA file for the reference.')

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
    parser.add_argument(
        "-v", "--version", action="version", version="%(prog)s {}".format(VERSION)
    )

    parser.add_argument(
        "--kD_cutoff", default=500, help="Cutoff value for the kD, default is 500",
    )

    return parser.parse_args()


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
    print("kD Cutoff Value:", args.kD_cutoff)
    print("Ensembl files:", args.gtf_file, args.cdna_file)
    if args.patient_data_file:
        print("patient_data_file File:", args.patient_data_file)

    main(args)

