process SNPPILEUP {
    tag "$meta.id"
    label 'process_medium'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/facets-suite:2.0.9':
        'docker.io/mskcc/facets-suite:2.0.9' }"

    input:

    tuple val(meta),  path(normal), path(normal_index), path(tumor),  path(tumor_index)
    tuple val(meta1), path(dbsnp),  path(dbsnp_index)


    output:
    tuple val(meta), path("*.snp_pileup.gz")   , emit: pileup
    path "versions.yml"                        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    /usr/bin/snp-pileup \
        ${args} \
        ${dbsnp} \
        ${prefix}.snp_pileup.gz \
        ${normal} \
        ${tumor}
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        htslib: 1.5
        htstools: 0.1.1
        r: 3.6.1
    END_VERSIONS
    """

    stub:
    def args =   task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}.snp_pileup.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        htslib: 1.5
        htstools: 0.1.1
        r: 3.6.1
    END_VERSIONS
    """
}