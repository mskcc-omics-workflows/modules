process GBCMS {
    tag "$meta.id"
    label 'process_single'
    container "ghcr.io/msk-access/gbcms:1.2.5"
    
    input:
    tuple val(meta), path(bam), path(bambai), path(variant_file), val(output)
    path(fasta) 
    path(fastafai)

    output:
     tuple val(meta), path('*.{vcf,maf}') , emit: variant_file
     tuple val(meta), path("versions.yml")   , emit: versions

    when:
        task.ext.when == null || task.ext.when
    script:
    // if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
    //     error "GetBaseCountsMultiSample module does not support Conda. Please use Docker / Singularity / Podman instead."
    // }
    def args = task.ext.args ?: ''
    def sample = meta.sample
    // determine if input file is a maf of vcf 

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
    --output ${output} \\
    --bam $sample:${bam} $args
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}": 
        GetBaseCountsMultiSample: \$(echo \$(GetBaseCountsMultiSample --help) | grep -oP '[0-9]\\.[0-9]\\.[0-9]')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    echo stub > 'variant_file.maf'
    echo "${task.process}:" > versions.yml
    echo 'GetBaseCountsMultiSample: 1.2.5' >> versions.yml

    """
}
