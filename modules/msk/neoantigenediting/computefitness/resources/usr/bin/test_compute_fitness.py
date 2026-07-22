#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Regression tests for the compute_fitness.py scoring guard.

Covers a bug where non-standard residues (e.g. "*", "X") in a
neoantigen/WT peptide pair, or a zero Kd/KdWT, crashed or silently
mis-scored neoantigens instead of being safely zeroed out.
"""

import os
import sys

import pytest

sys.path.insert(0, os.path.dirname(__file__))

from compute_fitness import score_neoantigen  # noqa: E402
from EpitopeDistance import EpitopeDistance  # noqa: E402


@pytest.fixture(scope="module")
def epidist():
    return EpitopeDistance()


def make_neo(sequence, wt_sequence, kd=100.0, kdwt=1000.0, r=0.5):
    return {
        "sequence": sequence,
        "WT_sequence": wt_sequence,
        "Kd": kd,
        "KdWT": kdwt,
        "R": r,
    }


def test_non_standard_residue_is_zeroed(epidist):
    neo = make_neo("ACDEFGHI*", "ACDEFGHIK")
    score_neoantigen(neo, epidist, w=0.5)
    assert neo["logC"] == 0.0
    assert neo["logA"] == 0.0
    assert neo["quality"] == 0.0


def test_non_standard_residue_X_is_zeroed(epidist):
    neo = make_neo("ACDEFGHIX", "ACDEFGHIK")
    score_neoantigen(neo, epidist, w=0.5)
    assert neo["logC"] == 0.0
    assert neo["logA"] == 0.0
    assert neo["quality"] == 0.0


def test_zero_kd_is_zeroed(epidist):
    neo = make_neo("ACDEFGHIK", "ACDEFGHIK", kd=0.0)
    score_neoantigen(neo, epidist, w=0.5)
    assert neo["logC"] == 0.0
    assert neo["logA"] == 0.0
    assert neo["quality"] == 0.0


def test_zero_kdwt_is_zeroed(epidist):
    neo = make_neo("ACDEFGHIK", "ACDEFGHIK", kdwt=0.0)
    score_neoantigen(neo, epidist, w=0.5)
    assert neo["logC"] == 0.0
    assert neo["logA"] == 0.0
    assert neo["quality"] == 0.0


def test_clean_standard_residue_input_is_scored(epidist):
    neo = make_neo("ACDEFGHIK", "ACDEFGHIL", kd=100.0, kdwt=1000.0, r=0.5)
    score_neoantigen(neo, epidist, w=0.5)
    assert neo["logC"] != 0.0 or neo["logA"] != 0.0
    assert neo["quality"] != 0.0
    assert neo["logA"] == pytest.approx(2.302585092994046)
