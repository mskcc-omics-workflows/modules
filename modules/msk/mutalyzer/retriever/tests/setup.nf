process GUNZIP_FASTA {
    container "ghcr.io/mskcc-omics-workflows/neoantigen-utils-base:1.4.0"

    input:
    path fasta_gzip

    output:
    path "unzipped.fa", emit: fasta

    script:
    """
    gunzip -c ${fasta_gzip} > unzipped.fa
    """
}
