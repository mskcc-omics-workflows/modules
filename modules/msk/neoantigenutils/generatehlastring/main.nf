process NEOANTIGENUTILS_GENERATEHLASTRING{
    tag "$meta.id"
    label 'process_single'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/neoantigen-utils-base:1.0.0':
        'docker.io/mskcc/neoantigen-utils-base:1.0.0' }"

    input:
    tuple val(meta),  path(inputHLA)

    output:
    tuple val(meta), stdout,   emit: hlastring
    path "versions.yml",       emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    generateHLAString.sh -f ${inputHLA}


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        generateHLAstring: \$(echo \$(generateHLAString.sh -v))
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
        echo "HLA-test:01,HLA-test2:02"
        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            generateHLAstring: \$(echo \$(generateHLAString.sh -v))
        END_VERSIONS
    """
}
