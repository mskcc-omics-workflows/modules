import pytest
import tempfile
import os
from prepare_fusion_fasta import parse_agfusion_dir, extract_junction_peptides, write_fasta_pair


class TestExtractJunctionPeptides:
    def test_9mer_window(self):
        fusion_seq = "ABCDEFGHIJKLMNOP"
        junction_pos = 8
        peptides = extract_junction_peptides(fusion_seq, junction_pos, peptide_lengths=[9])
        assert len(peptides) > 0
        for pep in peptides:
            assert len(pep) == 9

    def test_multiple_lengths(self):
        fusion_seq = "ABCDEFGHIJKLMNOPQRSTUVWX"
        junction_pos = 12
        peptides = extract_junction_peptides(fusion_seq, junction_pos, peptide_lengths=[9, 10, 11])
        lengths = set(len(p) for p in peptides)
        assert 9 in lengths
        assert 10 in lengths
        assert 11 in lengths

    def test_short_sequence_handled(self):
        fusion_seq = "ABCD"
        junction_pos = 2
        peptides = extract_junction_peptides(fusion_seq, junction_pos, peptide_lengths=[9])
        assert len(peptides) == 0


class TestParseAgfusionDir:
    def test_reads_fa_files(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            fusion_dir = os.path.join(tmpdir, "EGFR-SEPT14")
            os.makedirs(fusion_dir)
            with open(os.path.join(fusion_dir, "EGFR-SEPT14_protein.fa"), "w") as f:
                f.write(">ENST00000275493-ENST00000400454\n")
                f.write("MRPSGTAGAALLALLAALCPASRALEEKKVCQGTSNKLTQLGTFEDHFLSLQRMFNNCEVVLGNLEITYVQRNYDLSFLKTIQEVAGYVLIALNTVERIPLENLQIIRGNMYYENSYALAVLSNYDANKTGLKELPMRNLQEILHGAVRFSNNPALCNVESIQWRD\n")

            fusions = parse_agfusion_dir(tmpdir)
            assert len(fusions) >= 1
            assert fusions[0]["gene_pair"] == "EGFR-SEPT14"


class TestWriteFastaPair:
    def test_creates_mut_and_wt_files(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            peptides = [
                {"id": "EGFR_SEPT14_1", "mut_seq": "ABCDEFGHI", "wt_seq": "ABCXYZGHI"}
            ]
            mut_path = os.path.join(tmpdir, "test.SV.MUT.fa")
            wt_path = os.path.join(tmpdir, "test.SV.WT.fa")
            write_fasta_pair(peptides, mut_path, wt_path)
            assert os.path.exists(mut_path)
            assert os.path.exists(wt_path)
            with open(mut_path) as f:
                content = f.read()
                assert ">EGFR_SEPT14_1_M" in content
                assert "ABCDEFGHI" in content
