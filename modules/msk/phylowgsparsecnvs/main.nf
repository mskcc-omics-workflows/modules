process PHYLOWGSPARSECNVS {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'mskcc/phylowgs:v1.4-msk':
        'mskcc/phylowgs:v1.4-msk' }"

    input:
    tuple val(meta), path(facetsgenelevel)

    output:
    tuple val(meta), path("cnvs.txt"), emit: cnv
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    python2 \\
        /usr/bin/parser/parse_cnvs.py \\
        ${args} \\
        ${facetsgenelevel}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        phylowgsparsecnvs: \$PHYLOWGS_TAG
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch cnvs.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        phylowgsparsecnvs: \$PHYLOWGS_TAG
    END_VERSIONS
    """
}
