import pytest
import pandas as pd
import tempfile
import os
from annotate_rna import build_mutation_id, extract_rna_columns_from_maf, annotate_expression, merge_annotations


class TestBuildMutationId:
    def test_snp(self):
        row = {"Chromosome": "7", "Start_Position": 55259515,
               "Reference_Allele": "T", "Tumor_Seq_Allele2": "G",
               "Variant_Type": "SNP"}
        assert build_mutation_id(row) == "7_55259515_T_G"

    def test_del(self):
        row = {"Chromosome": "17", "Start_Position": 7577120,
               "Reference_Allele": "AC", "Tumor_Seq_Allele2": "-",
               "Variant_Type": "DEL"}
        assert build_mutation_id(row) == "17_7577120_AC_D"

    def test_ins(self):
        row = {"Chromosome": "12", "Start_Position": 25398284,
               "Reference_Allele": "-", "Tumor_Seq_Allele2": "AGT",
               "Variant_Type": "INS"}
        assert build_mutation_id(row) == "12_25398284_I_AGT"

    def test_dnp(self):
        row = {"Chromosome": "1", "Start_Position": 115256530,
               "Reference_Allele": "TT", "Tumor_Seq_Allele2": "AA",
               "Variant_Type": "DNP"}
        assert build_mutation_id(row) == "1_115256530_TT_AA"


class TestExtractRnaColumns:
    def test_maf_with_rna_columns(self):
        maf_df = pd.DataFrame({
            "Chromosome": ["7", "17"],
            "Start_Position": [55259515, 7577120],
            "Reference_Allele": ["T", "AC"],
            "Tumor_Seq_Allele2": ["G", "-"],
            "Variant_Type": ["SNP", "DEL"],
            "Hugo_Symbol": ["EGFR", "TP53"],
            "rna_t_alt_count": [15, 0],
            "rna_t_ref_count": [85, 120],
            "rna_t_variant_frequency": [0.15, 0.0],
        })
        result = extract_rna_columns_from_maf(maf_df)
        assert len(result) == 2
        assert result.loc[result["mutation_id"] == "7_55259515_T_G", "rna_alt_count"].values[0] == 15
        assert result.loc[result["mutation_id"] == "17_7577120_AC_D", "rna_vaf"].values[0] == 0.0

    def test_maf_without_rna_columns(self):
        maf_df = pd.DataFrame({
            "Chromosome": ["7"],
            "Start_Position": [55259515],
            "Reference_Allele": ["T"],
            "Tumor_Seq_Allele2": ["G"],
            "Variant_Type": ["SNP"],
            "Hugo_Symbol": ["EGFR"],
        })
        result = extract_rna_columns_from_maf(maf_df)
        assert len(result) == 1
        assert pd.isna(result["rna_alt_count"].values[0])
        assert pd.isna(result["rna_vaf"].values[0])


class TestAnnotateExpression:
    def test_kallisto_to_gene_tpm(self):
        with tempfile.NamedTemporaryFile(mode='w', suffix='.tsv', delete=False) as f:
            f.write("target_id\tlength\teff_length\test_counts\ttpm\n")
            f.write("ENST00000275493.7\t3188\t2939.42\t1500\t45.2\n")
            f.write("ENST00000454757.1\t637\t388.42\t50\t1.1\n")
            abundance_path = f.name

        with tempfile.NamedTemporaryFile(mode='w', suffix='.gtf', delete=False) as f:
            f.write('chr7\tensembl\ttranscript\t55019017\t55211628\t.\t+\t.\tgene_id "ENSG00000146648"; transcript_id "ENST00000275493"; gene_name "EGFR";\n')
            f.write('chr7\tensembl\ttranscript\t55019017\t55211628\t.\t+\t.\tgene_id "ENSG00000146648"; transcript_id "ENST00000454757"; gene_name "EGFR";\n')
            gtf_path = f.name

        result = annotate_expression(abundance_path, gtf_path)
        assert "EGFR" in result["Gene"].values
        egfr_tpm = result.loc[result["Gene"] == "EGFR", "rna_tpm"].values[0]
        assert abs(egfr_tpm - 46.3) < 0.1

        os.unlink(abundance_path)
        os.unlink(gtf_path)

    def test_no_kallisto_returns_empty(self):
        result = annotate_expression(None, None)
        assert result is None


class TestMergeAnnotations:
    def test_full_merge(self):
        neo_tsv = pd.DataFrame({
            "id": ["neo1", "neo2"],
            "mutation_id": ["7_55259515_T_G", "17_7577120_AC_D"],
            "Gene": ["EGFR", "TP53"],
            "quality": [0.85, 0.42],
        })
        rna_vaf = pd.DataFrame({
            "mutation_id": ["7_55259515_T_G", "17_7577120_AC_D"],
            "rna_alt_count": [15, 0],
            "rna_ref_count": [85, 120],
            "rna_vaf": [0.15, 0.0],
        })
        expression = pd.DataFrame({
            "Gene": ["EGFR", "TP53"],
            "rna_tpm": [46.3, 0.2],
        })
        result = merge_annotations(neo_tsv, rna_vaf, expression, tpm_threshold=1.0)
        assert "rna_expressed" in result.columns
        assert result.loc[result["Gene"] == "EGFR", "rna_expressed"].values[0] == True
        assert result.loc[result["Gene"] == "TP53", "rna_expressed"].values[0] == False
