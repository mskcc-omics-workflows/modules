process PHYLOWGS_WRITERESULTS {
    tag "$meta.id"
    label 'process_medium'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/phylowgs:v1.4-msk':
        'docker.io/mskcc/phylowgs:v1.4-msk' }"

    input:
    tuple val(meta), path(trees)

    output:
    tuple val(meta), path("*.summ.json.gz")     , emit: summ
    tuple val(meta), path("*.muts.json.gz")     , emit: muts
    tuple val(meta), path("*.mutass.zip")       , emit: mutass
    path "versions.yml"                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    python2 \\
         /usr/bin/write_results.py \\
        --include-ssm-names \\
        ${prefix} \\
        ${trees} \\
        ${prefix}.summ.json.gz \\
        ${prefix}.muts.json.gz \\
        ${prefix}.mutass.zip
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        phylowgs: \$PHYLOWGS_TAG
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.summ.json.gz
    touch ${prefix}.muts.json.gz
    touch ${prefix}.mutass.zip

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        phylowgs: \$PHYLOWGS_TAG
    END_VERSIONS
    """
}
