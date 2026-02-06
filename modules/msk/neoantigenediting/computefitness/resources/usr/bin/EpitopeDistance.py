#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Class for computing the crossreactivity distance between two epitopes
    Copyright (C) 2022 Zachary Sethna

    Use is subject to the included term of use found at
    https://github.com/LukszaLab/NeoantigenEditing
"""
import numpy as np
import json
import os

#%
class EpitopeDistance(object):
    """Base class for epitope crossreactivity.

    Model:
        dist({a_i}, {b_i}) = \sum_i d_i M_ab(a_i, b_i)

    Attributes
    ----------
    amino_acids : str
        Allowed amino acids in specified order.

    amino_acid_dict : dict
        Dictionary of amino acids and corresponding indicies

    d_i : ndarray
        Position scaling array d_i.
        d_i.shape == (9,)

    M_ab : ndarray
        Amino acid substitution matrix. Indexed by the order of amino_acids.
        M_ab.shape == (21, 21)


    """

    def __init__(
        self,
        amino_acids="ACDEFGHIKLMNPQRSTVWYX",
        model_file=None,
    ):
        """Initialize class and compute M_ab.

        :param amino_acids: str
        :param model_file: str or None
            Path to JSON model file. If None, uses bundled default.
        """

        self.amino_acids = amino_acids
        self.amino_acid_dict = {}
        for i, aa in enumerate(self.amino_acids):
            self.amino_acid_dict[aa.upper()] = i
            self.amino_acid_dict[aa.lower()] = i

        if model_file is None:
            model_file = os.path.join(
                os.path.dirname(__file__), "distance_data", "epitope_distance_model_parameters.json"
            )
        self.set_model(model_file)

        self.load_blosum62_mat()

    def set_model(self, model_file):
        """Load model and format substitution matrix M_ab."""
        with open(model_file, "r") as modelf:
            c_model = json.load(modelf)
        if "d_i" not in c_model:
            self.d_i = [1 for _ in range(9)]
        else:
            self.d_i = c_model["d_i"]
        if "M_ab" in c_model:
            self.M_ab_dict = c_model["M_ab"]
        else:
            self.M_ab_dict = c_model
        values = [val for (key, val) in self.M_ab_dict.items() if len(set(key.split("->"))) > 1]
        ave_value = np.mean(values)

        M_ab = np.zeros((len(self.amino_acids), len(self.amino_acids)))
        for i, aaA in enumerate(self.amino_acids):
            for j, aaB in enumerate(self.amino_acids):
                akey = aaA + "->" + aaB
                bkey = aaB + "->" + aaA
                try:
                    M_ab[i, j] = self.M_ab_dict[akey]
                except KeyError:
                    try:
                        M_ab[i, j] = self.M_ab_dict[bkey]
                    except KeyError:
                        if i == j:
                            M_ab[i, j] = 0
                        else:
                            M_ab[i, j] = ave_value
        self.M_ab = M_ab

    def epitope_dist(self, epiA, epiB):
        """Compute the model difference between epitopes epiA and epiB.

        Ignores capitalization. Supports variable-length epitopes.

        Model:
            dist({a_i}, {b_i}) = \sum_i d_i M_ab(a_i, b_i)

        If epitope length matches d_i length, uses position-weighted distances.
        Otherwise, sums M_ab values without d_i weighting.
        """
        nlen = len(self.d_i)
        if len(epiA) == nlen:
            return sum(
                [
                    self.d_i[i]
                    * self.M_ab[
                        self.amino_acid_dict[epiA[i]], self.amino_acid_dict[epiB[i]]
                    ]
                    for i in range(nlen)
                ]
            )
        else:
            return sum(
                [
                    self.M_ab[
                        self.amino_acid_dict[epiA[i]], self.amino_acid_dict[epiB[i]]
                    ]
                    for i in range(len(epiA))
                ]
            )

    def get_M_ab(self, A, B):
        """Get the M_ab value for amino acid pair A, B."""
        return self.M_ab[self.amino_acid_dict[A], self.amino_acid_dict[B]]

    def load_blosum62_mat(self):
        """Load BLOSUM62 substitution matrix."""
        raw_blosum62_mat_str = """
   A  R  N  D  C  Q  E  G  H  I  L  K  M  F  P  S  T  W  Y  V  B  Z  X  *
A  4 -1 -2 -2  0 -1 -1  0 -2 -1 -1 -1 -1 -2 -1  1  0 -3 -2  0 -2 -1  0 -4
R -1  5  0 -2 -3  1  0 -2  0 -3 -2  2 -1 -3 -2 -1 -1 -3 -2 -3 -1  0 -1 -4
N -2  0  6  1 -3  0  0  0  1 -3 -3  0 -2 -3 -2  1  0 -4 -2 -3  3  0 -1 -4
D -2 -2  1  6 -3  0  2 -1 -1 -3 -4 -1 -3 -3 -1  0 -1 -4 -3 -3  4  1 -1 -4
C  0 -3 -3 -3  9 -3 -4 -3 -3 -1 -1 -3 -1 -2 -3 -1 -1 -2 -2 -1 -3 -3 -2 -4
Q -1  1  0  0 -3  5  2 -2  0 -3 -2  1  0 -3 -1  0 -1 -2 -1 -2  0  3 -1 -4
E -1  0  0  2 -4  2  5 -2  0 -3 -3  1 -2 -3 -1  0 -1 -3 -2 -2  1  4 -1 -4
G  0 -2  0 -1 -3 -2 -2  6 -2 -4 -4 -2 -3 -3 -2  0 -2 -2 -3 -3 -1 -2 -1 -4
H -2  0  1 -1 -3  0  0 -2  8 -3 -3 -1 -2 -1 -2 -1 -2 -2  2 -3  0  0 -1 -4
I -1 -3 -3 -3 -1 -3 -3 -4 -3  4  2 -3  1  0 -3 -2 -1 -3 -1  3 -3 -3 -1 -4
L -1 -2 -3 -4 -1 -2 -3 -4 -3  2  4 -2  2  0 -3 -2 -1 -2 -1  1 -4 -3 -1 -4
K -1  2  0 -1 -3  1  1 -2 -1 -3 -2  5 -1 -3 -1  0 -1 -3 -2 -2  0  1 -1 -4
M -1 -1 -2 -3 -1  0 -2 -3 -2  1  2 -1  5  0 -2 -1 -1 -1 -1  1 -3 -1 -1 -4
F -2 -3 -3 -3 -2 -3 -3 -3 -1  0  0 -3  0  6 -4 -2 -2  1  3 -1 -3 -3 -1 -4
P -1 -2 -2 -1 -3 -1 -1 -2 -2 -3 -3 -1 -2 -4  7 -1 -1 -4 -3 -2 -2 -1 -2 -4
S  1 -1  1  0 -1  0  0  0 -1 -2 -2  0 -1 -2 -1  4  1 -3 -2 -2  0  0  0 -4
T  0 -1  0 -1 -1 -1 -1 -2 -2 -1 -1 -1 -1 -2 -1  1  5 -2 -2  0 -1 -1  0 -4
W -3 -3 -4 -4 -2 -2 -3 -2 -2 -3 -2 -3 -1  1 -4 -3 -2 11  2 -3 -4 -3 -2 -4
Y -2 -2 -2 -3 -2 -1 -2 -3  2 -1 -1 -2 -1  3 -3 -2 -2  2  7 -1 -3 -2 -1 -4
V  0 -3 -3 -3 -1 -2 -2 -3 -3  3  1 -2  1 -1 -2 -2  0 -3 -1  4 -3 -2 -1 -4
B -2 -1  3  4 -3  0  1 -1  0 -3 -4  0 -3 -3 -2  0 -1 -4 -3 -3  4  1 -1 -4
Z -1  0  0  1 -3  3  4 -2  0 -3 -3  1 -1 -3 -1  0 -1 -3 -2 -2  1  4 -1 -4
X  0 -1 -1 -1 -2 -1 -1 -1 -1 -1 -1 -1 -1 -1 -2  0  0 -2 -1 -1 -1 -1 -1 -4
* -4 -4 -4 -4 -4 -4 -4 -4 -4 -4 -4 -4 -4 -4 -4 -4 -4 -4 -4 -4 -4 -4 -4  1
"""
        blosum62_mat_str_list = [l.split() for l in raw_blosum62_mat_str.strip().split("\n")]
        blosum_aa_order = [blosum62_mat_str_list[0].index(aa) for aa in self.amino_acids]

        blosum62_mat = np.zeros((len(self.amino_acids), len(self.amino_acids)))
        for i, bl_ind in enumerate(blosum_aa_order):
            blosum62_mat[i] = np.array(
                [int(x) for x in blosum62_mat_str_list[bl_ind + 1][1:]]
            )[blosum_aa_order]
        self.blosum62_mat = blosum62_mat
        self.blosum62_dict = {
            "->".join([aaA, aaB]): self.blosum62_mat[i, j]
            for i, aaA in enumerate(self.amino_acids)
            for j, aaB in enumerate(self.amino_acids)
        }

    def run_epitope_distance(self, pep_dict):
        """Run epitope_dist on a pep_dict.

        :param pep_dict: dictionary with { pid: {WT: XXX, MT: XXX} } as a minimal requirement
        :return: pep_dict with 'logC' added
        """
        for pid in pep_dict:
            pep_dict[pid]["logC"] = self.epitope_dist(pep_dict[pid]["WT"], pep_dict[pid]["MT"])

        return pep_dict
