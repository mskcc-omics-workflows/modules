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
        model_file=os.path.join(
            os.path.dirname(__file__), "distance_data", "epitope_distance_model_parameters.json"
        ),
        amino_acids="ACDEFGHIKLMNPQRSTVWYX",
    ):
        """Initialize class and compute M_ab."""

        self.amino_acids = amino_acids
        # self.amino_acid_dict = {aa: i for i, aa in enumerate(self.amino_acids)}
        self.amino_acid_dict = {}
        for i, aa in enumerate(self.amino_acids):
            self.amino_acid_dict[aa.upper()] = i
            self.amino_acid_dict[aa.lower()] = i

        self.set_model(model_file)

    def set_model(self, model_file):
        """Load model and format substitution matrix M_ab."""
        with open(model_file, "r") as modelf:
            c_model = json.load(modelf)
        self.d_i = c_model.get("d_i", [1] * 9)
        self.M_ab_dict = c_model.get("M_ab", c_model)
        avg_val = np.mean(list(self.M_ab_dict.values())) if self.M_ab_dict else 0.0
        M_ab = np.zeros((len(self.amino_acids), len(self.amino_acids)))
        for i, aaA in enumerate(self.amino_acids):
            for j, aaB in enumerate(self.amino_acids):
                key = aaA + "->" + aaB
                rev_key = aaB + "->" + aaA
                if key in self.M_ab_dict:
                    M_ab[i, j] = self.M_ab_dict[key]
                elif rev_key in self.M_ab_dict:
                    M_ab[i, j] = self.M_ab_dict[rev_key]
                else:
                    M_ab[i, j] = avg_val
        self.M_ab = M_ab

    def epitope_dist(self, epiA, epiB):
        """Compute the model difference between epitopes epiA and epiB.

        Ignores capitalization. Supports variable-length epitopes: if the
        epitope length matches len(d_i), position weights are applied;
        otherwise the raw M_ab values are summed without d_i weighting.

        Model:
            dist({a_i}, {b_i}) = \sum_i d_i M_ab(a_i, b_i)
        """
        n = min(len(epiA), len(epiB))
        if n == len(self.d_i):
            return sum(
                self.d_i[i]
                * self.M_ab[
                    self.amino_acid_dict[epiA[i]], self.amino_acid_dict[epiB[i]]
                ]
                for i in range(n)
            )
        else:
            return sum(
                self.M_ab[
                    self.amino_acid_dict[epiA[i]], self.amino_acid_dict[epiB[i]]
                ]
                for i in range(n)
            )
