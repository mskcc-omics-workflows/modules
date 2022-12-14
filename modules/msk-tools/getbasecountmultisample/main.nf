
process GETBASECOUNTMULTISAMPLE {
    tag "DEMUX_${meta.id}"
    label 'process_low'
    if (params.enable_conda) {
        exit 1, "Conda environments cannot be used for getbasecountmultisample. Please use docker."
    }
    container "ghcr.io/mskcc-omics-workflows/gbcms:1.2.5"
    
    input:
    tuple val(meta), path(fasta), path(fastafai), path(bam), path(bambai), path(variant_file), val(sample), val(output), val(options)

    output:
     path('variant_file.{vcf,maf}')
     path("versions.yml")
     
    script:
    // determine if input file is a maf of vcf 
    // the --maf and --vcf inputs are mutually input exclusive parameters.
    // Both are part of the same subcommand. Thus warrants groovy scripting. 
    def input_ext = variant_file.getExtension()
    def variant_input = ''
    if(input_ext == 'maf') {
        variant_input = '--maf ' + variant_file
    } 
    if(input_ext == 'vcf'){
            variant_input = '--vcf ' + variant_file
    }
    // raise exception if file extension other than maf or vcf is passed 
    if(variant_input == ''){
        throw new Exception("Variant file must be maf or vcf, not ${input_ext}")
    }
    """
    GetBaseCountsMultiSample --fasta ${fasta} \\
    ${variant_input} \\
    --output ${output} \\
    --bam $sample:${bam} ${options.args}
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        \$(GetBaseCountsMultiSample --help | grep "GetBaseCountsMultiSample [0-9].[0-9.].[0-9.]")
    END_VERSIONS
    """
}
