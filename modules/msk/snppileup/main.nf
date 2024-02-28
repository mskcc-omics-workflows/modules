process SNPPILEUP {
    tag "$meta.id"
    label 'process_medium'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/facets-suite:2.0.9':
        'docker.io/mskcc/facets-suite:2.0.9' }"

    input:

    tuple val(meta),  path(normal), path(normal_index), path(tumor),  path(tumor_index), path(additional_bams, arity: '0..*'), path(additional_bam_index, arity: '0..*')
    tuple val(meta1), path(dbsnp),  path(dbsnp_index)


    output:
    tuple val(meta), path("*.snp_pileup.gz")   , emit: pileup
    path "versions.yml"                        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def extra_bams = additional_bams ?: ''

    """
    /usr/bin/snp-pileup \
        ${args} \
        ${dbsnp} \
        ${prefix}.snp_pileup.gz \
        ${normal} \
        ${tumor} \
        ${extra_bams}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        htslib: \$(bgzip --version | grep -oP '(?<=\\(htslib\\) ).*')
        htstools: 0.1.1
        r: \$(R --version | grep -oP '(?<=R version ).*(?=\\()')
    END_VERSIONS
    """

    stub:
    def args =   task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    echo "stub test" >> ${prefix}.snp_pileup
    gzip ${prefix}.snp_pileup
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        htslib: \$(bgzip --version | grep -oP '(?<=\\(htslib\\) ).*')
        htstools: 0.1.1
        r: \$(R --version | grep -oP '(?<=R version ).*(?=\\()')
    END_VERSIONS
    """
}