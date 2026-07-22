"""Unit tests for the multi-transcript parsing in generateMutFasta.py.

Covers the adaptation of the parser to Genome Nexus' ``Additional_Transcripts``
column (``-m extended``): field order
``Transcript_ID,Hugo_Symbol,HGVSp_Short,HGVSc,Variant_Classification``, the MAF
``Variant_Classification`` vocabulary, and the fact that the canonical transcript
is NOT present in that column (so it must be emitted from the main MAF columns).

Run with:  pytest modules/msk/generatemutfasta/tests/test_generatemutfasta.py
"""

import importlib.util
import sys
import types
from pathlib import Path

import pandas as pd
import pytest


def _load_module():
    """Import generateMutFasta.py by path, stubbing the runtime-only mutalyzer dep.

    generateMutFasta imports ``from mutalyzer.normalizer import normalize`` at
    module load; mutalyzer is heavy and not needed for parsing, so stub it.
    """
    mutalyzer = types.ModuleType("mutalyzer")
    normalizer = types.ModuleType("mutalyzer.normalizer")
    normalizer.normalize = lambda *a, **k: {}
    mutalyzer.normalizer = normalizer
    sys.modules.setdefault("mutalyzer", mutalyzer)
    sys.modules.setdefault("mutalyzer.normalizer", normalizer)

    script = (
        Path(__file__).resolve().parents[1]
        / "resources"
        / "usr"
        / "bin"
        / "generateMutFasta.py"
    )
    spec = importlib.util.spec_from_file_location("generatemutfasta", script)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


gmf = _load_module()


# ---------------------------------------------------------------------------
# parse_additional_transcripts
# ---------------------------------------------------------------------------


def test_single_entry_maps_gn_field_order():
    col = "ENST00000379389,ISG15,p.Ile36=,c.106A>G,Missense_Mutation"
    assert gmf.parse_additional_transcripts(col) == [
        ("ISG15", "Missense_Mutation", "p.Ile36=", "ENST00000379389", "", "c.106A>G")
    ]


def test_multiple_entries_semicolon_separated():
    col = (
        "ENST1,GENEA,p.A1,c.10A>G,Missense_Mutation;"
        "ENST2,GENEB,p.B1,c.20del,Frame_Shift_Del"
    )
    out = gmf.parse_additional_transcripts(col)
    assert [e[3] for e in out] == ["ENST1", "ENST2"]
    assert [e[5] for e in out] == ["c.10A>G", "c.20del"]
    assert [e[1] for e in out] == ["Missense_Mutation", "Frame_Shift_Del"]


def test_refseq_is_always_empty():
    # Genome Nexus does not emit a per-transcript RefSeq in this column.
    (effect,) = gmf.parse_additional_transcripts(
        "ENST1,GENE,p.X,c.1A>G,Missense_Mutation"
    )
    assert effect[4] == ""


def test_whitespace_is_trimmed():
    col = " ENST1 , GENE , p.X , c.1A>G , Missense_Mutation "
    assert gmf.parse_additional_transcripts(col) == [
        ("GENE", "Missense_Mutation", "p.X", "ENST1", "", "c.1A>G")
    ]


def test_hgvsc_n_prefix_at_expected_position():
    (effect,) = gmf.parse_additional_transcripts(
        "ENST1,GENE,p.X,n.100A>G,Splice_Site"
    )
    assert effect[5] == "n.100A>G"


def test_hgvsc_located_by_prefix_when_position_shifts():
    # Robustness: if HGVSc is not in slot 3, it is still found by its c./n. prefix.
    (effect,) = gmf.parse_additional_transcripts(
        "ENST1,GENE,p.X,Missense_Mutation,c.10A>G"
    )
    assert effect[5] == "c.10A>G"


def test_missing_hgvsc_is_empty_string():
    # Four fields, no c./n. anywhere -> hgvsc "" (caller warns and skips).
    (effect,) = gmf.parse_additional_transcripts("ENST1,GENE,p.X,Silent")
    assert effect[5] == ""


def test_short_record_is_skipped():
    assert gmf.parse_additional_transcripts("ENST1,GENE,p.X") == []


def test_empty_transcript_id_is_skipped():
    assert gmf.parse_additional_transcripts(",GENE,p.X,c.1A>G,Missense_Mutation") == []


def test_trailing_and_blank_entries_tolerated():
    col = "ENST1,GENE,p.X,c.1A>G,Missense_Mutation;;   ;"
    out = gmf.parse_additional_transcripts(col)
    assert len(out) == 1 and out[0][3] == "ENST1"


@pytest.mark.parametrize("empty", [None, float("nan"), pd.NA])
def test_empty_inputs_return_empty_list(empty):
    assert gmf.parse_additional_transcripts(empty) == []


# ---------------------------------------------------------------------------
# is_neoantigen_capable  (MAF Variant_Classification + legacy VEP terms)
# ---------------------------------------------------------------------------


@pytest.mark.parametrize(
    "classification",
    [
        "Missense_Mutation",
        "Nonsense_Mutation",
        "Nonstop_Mutation",
        "Frame_Shift_Del",
        "Frame_Shift_Ins",
        "In_Frame_Del",
        "In_Frame_Ins",
        "Splice_Site",
        "Translation_Start_Site",
        # legacy VEP consequence terms still accepted
        "missense_variant",
        "frameshift_variant",
        "inframe_insertion",
        "splice_acceptor_variant",
    ],
)
def test_capable_classifications(classification):
    assert gmf.is_neoantigen_capable(classification) is True


@pytest.mark.parametrize(
    "classification",
    ["Silent", "Intron", "3'UTR", "5'Flank", "RNA", "IGR", "Splice_Region", "", None],
)
def test_non_capable_classifications(classification):
    assert gmf.is_neoantigen_capable(classification) is False


# ---------------------------------------------------------------------------
# process_alt_transcripts  (canonical row must be emitted from main MAF columns)
# ---------------------------------------------------------------------------


class _FakeMut:
    def __init__(self, row, mt_altered_aa, identifier_key):
        self.maf_row = row
        self.mt_altered_aa = mt_altered_aa
        self.identifier_key = identifier_key


def _row(additional_transcripts, transcript_id="ENST_CANON"):
    return pd.Series(
        {
            "Chromosome": "1",
            "Start_Position": 100,
            "Reference_Allele": "A",
            "Tumor_Seq_Allele2": "G",
            "Transcript_ID": transcript_id,
            "RefSeq": "NM_1",
            "HGVSp_Short": "p.Canon",
            "Variant_Classification": "Missense_Mutation",
            "Additional_Transcripts": additional_transcripts,
        }
    )


def test_canonical_row_always_emitted_and_alternates_parsed(monkeypatch):
    # Silent alt is dropped (not neoantigen-capable); missense alt is built.
    monkeypatch.setattr(
        gmf, "normalize_to_windows", lambda tx, hgvsc, pad: ("WTWINDOWAA", "MTWINDOWBB")
    )
    mut = _FakeMut(
        _row(
            "ENST_ALT1,GENE,p.Alt1,c.10A>G,Missense_Mutation;"
            "ENST_ALT2,GENE,p.Alt2,c.20A>G,Silent"
        ),
        mt_altered_aa="ANNOTATEDWINDOW",
        identifier_key="mut_key",
    )
    map_rows, surrogate_by_seq, surrogate_wt, alt_memo = [], {}, {}, {}
    gmf.process_alt_transcripts(mut, 8, surrogate_by_seq, surrogate_wt, map_rows, alt_memo)

    assert len(map_rows) == 2
    canonical = map_rows[0]
    assert canonical["transcript_id"] == "ENST_CANON"
    assert canonical["is_annotated"] is True
    assert canonical["same_as_annotated"] is True
    assert canonical["refseq"] == "NM_1"
    assert canonical["hgvsp_short"] == "p.Canon"
    assert canonical["surrogate_id"] == ""

    alt = map_rows[1]
    assert alt["transcript_id"] == "ENST_ALT1"
    assert alt["is_annotated"] is False
    assert alt["surrogate_id"] != ""  # net-new peptide got a surrogate
    assert len(surrogate_by_seq) == 1


def test_canonical_excluded_defensively_if_present_in_column(monkeypatch):
    monkeypatch.setattr(
        gmf, "normalize_to_windows", lambda tx, hgvsc, pad: ("WTWINDOWAA", "MTWINDOWBB")
    )
    # Column erroneously includes the canonical transcript; it must not duplicate.
    mut = _FakeMut(
        _row("ENST_CANON,GENE,p.Canon,c.5A>G,Missense_Mutation"),
        mt_altered_aa="ANNOTATEDWINDOW",
        identifier_key="mut_key",
    )
    map_rows = []
    gmf.process_alt_transcripts(mut, 8, {}, {}, map_rows, {})
    assert len(map_rows) == 1
    assert map_rows[0]["transcript_id"] == "ENST_CANON"
    assert map_rows[0]["is_annotated"] is True


def test_empty_column_still_emits_canonical(monkeypatch):
    monkeypatch.setattr(
        gmf, "normalize_to_windows", lambda tx, hgvsc, pad: ("WTWINDOWAA", "MTWINDOWBB")
    )
    mut = _FakeMut(_row(""), mt_altered_aa="ANNOTATEDWINDOW", identifier_key="mut_key")
    map_rows = []
    gmf.process_alt_transcripts(mut, 8, {}, {}, map_rows, {})
    assert len(map_rows) == 1
    assert map_rows[0]["is_annotated"] is True


# ---------------------------------------------------------------------------
# Primary-path resilience fixes (folded in from the large-run CHANGE_REPORT)
# generate_translated_sequences: offline versionless requery + protein guard
# ---------------------------------------------------------------------------


def _primary_row(hgvsc, transcript_id="ENST00000327044"):
    """A minimal non-synonymous MAF row the mutation() constructor accepts."""
    return pd.Series(
        {
            "Chromosome": "1",
            "Start_Position": 12345678,
            "Reference_Allele": "A",
            "Tumor_Seq_Allele2": "T",
            "Variant_Classification": "Missense_Mutation",
            "HGVSp_Short": "p.Gly214Cys",
            "HGVSc": hgvsc,
            "Transcript_ID": transcript_id,
        }
    )


def _capturing_normalize(captured):
    """A fake mutalyzer.normalize that records its query and returns a valid protein."""

    def _normalize(query):
        captured["q"] = query
        return {"protein": {"predicted": "MPQRS", "reference": "MPQKS"}}

    return _normalize


def test_full_form_hgvsc_requeries_versionless(monkeypatch):
    # A full-form HGVSc (contains ':') must be re-queried from the VERSIONLESS
    # Transcript_ID + the c. part, so mutalyzer resolves from cache with no network.
    captured = {}
    monkeypatch.setattr(gmf, "normalize", _capturing_normalize(captured))
    mut = gmf.mutation(_primary_row("ENST00000327044.6:c.640G>T"))
    mut.generate_translated_sequences(10)
    assert captured["q"] == "ENST00000327044:c.640G>T"


def test_plain_hgvsc_queried_as_is(monkeypatch):
    captured = {}
    monkeypatch.setattr(gmf, "normalize", _capturing_normalize(captured))
    mut = gmf.mutation(_primary_row("c.640G>T", transcript_id="ENST00000241312"))
    mut.generate_translated_sequences(10)
    assert captured["q"] == "ENST00000241312:c.640G>T"


def test_missing_protein_consequence_returns_minus1(monkeypatch):
    # No 'errors' and no usable 'protein' -> skip with -1 instead of KeyError crash.
    monkeypatch.setattr(gmf, "normalize", lambda q: {"warnings": []})
    mut = gmf.mutation(_primary_row("c.640G>T"))
    assert mut.generate_translated_sequences(10) == -1
