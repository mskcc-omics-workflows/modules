process PHYLOWGS_MULTIEVOLVE {
    tag "$meta.id"
    label 'process_high'

    container "ghcr.io/mskcc/neoantigen-pipeline/phylowgs:v1.5-msk"

    input:
    tuple val(meta), path(cnv_data), path(ssm_data)

    output:
    tuple val(meta), path("chains/trees.zip")   , emit: trees
    path "versions.yml"                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    python2 \\
        /usr/bin/phylowgs/multievolve.py  \\
        ${args} \\
        --ssms ${ssm_data} \\
        --cnvs ${cnv_data}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        phylowgs: \$PHYLOWGS_TAG
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir chains
    touch chains/trees.zip

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        phylowgs: \$PHYLOWGS_TAG
    END_VERSIONS
    """
}
