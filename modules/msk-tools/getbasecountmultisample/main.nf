
process GETBASECOUNTMULTISAMPLE {
    tag "DEMUX_${meta.id}"
    label 'process_low'
    if (params.enable_conda) {
        exit 1, "Conda environments cannot be used when using bcl2fastq. Please use docker or singularity containers."
    }
    container "ghcr.io/msk-access/gbcms:1.2.5"
    
    input:
    tuple val(meta), path(fasta), path(fastafai), path(bam), path(bambai), path(variant_file), val(sample), val(fragment_count), val(filter_duplicate), val(maq)

    output:
     path("test.vcf")
     
    script:
    def input_ext = variant_file.getExtension()
    def variant_input = ''
    if(input_ext == 'maf') {
        variant_input = '--maf ' + variant_file
    } 
    if(input_ext == 'vcf'){
            variant_input = '--vcf ' + variant_file
    }
    if(variant_input == ''){
        throw new Exception("Variant file must be maf or vcf, not ${input_ext}")
    }
    """
    GetBaseCountsMultiSample --fasta ${fasta} \\
    ${variant_input} \\
    --output test.vcf \\
    --fragment_count $fragment_count \\
    --filter_duplicate $filter_duplicate \\
    --maq $maq  \\
    --bam $sample:${bam}
    """
}
