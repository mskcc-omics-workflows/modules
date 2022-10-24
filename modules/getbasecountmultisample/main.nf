
process GETBASECOUNTMULTISAMPLE {
    tag "DEMUX_${meta.id}"
    label 'process_low'
    if (params.enable_conda) {
        exit 1, "Conda environments cannot be used when using bcl2fastq. Please use docker or singularity containers."
    }
    container "ghcr.io/msk-access/gbcms:1.2.5"
    
    input:
    tuple val(meta), path(fasta), path(fastafai), path(bam), path(bambai), path(vcf), val(sample), val(fragment_count), val(filter_duplicate), val(maq)

    output:
     path("test.vcf")

    script:
    """
    GetBaseCountsMultiSample --fasta ${fasta} \\
    --vcf ${vcf} \\
    --output test.vcf \\
    --fragment_count $fragment_count \\
    --filter_duplicate $filter_duplicate \\
    --maq $maq  \\
    --bam $sample:${bam}
    
    """
}
