// Emits a POLYSOLVER winners file whose second field is three digits
// (hla_b_18_177, hla_c_04_320, hla_c_07_348). The shared test-datasets
// winners.hla.txt only carries two-digit second fields, so it cannot
// exercise the truncation regression.
process WRITE_THREE_DIGIT_HLA {
    container "ghcr.io/mskcc-omics-workflows/neoantigen-utils-base:1.4.0"

    output:
    path "winners.hla.txt", emit: hla

    script:
    """
    printf 'HLA-A\\thla_a_02_01_01\\thla_a_02_01_01\\n' > winners.hla.txt
    printf 'HLA-B\\thla_b_08_01_01\\thla_b_18_177\\n'   >> winners.hla.txt
    printf 'HLA-C\\thla_c_04_320\\thla_c_07_348\\n'     >> winners.hla.txt
    """
}
