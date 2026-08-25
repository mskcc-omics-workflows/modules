process GBCMSRS_MERGE {
    tag "$meta.id"
    label 'process_single'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'ghcr.io/msk-access/gbcms:6.3.0':
        'ghcr.io/msk-access/gbcms:6.3.0' }"

    containerOptions { workflow.containerEngine in ['docker', 'podman'] ? "--entrypoint ''" : '' }

    input:
    tuple val(meta), val(types), path(mafs)

    output:
    tuple val(meta), path("*.merged.maf"), emit: merged
    path "versions.yml"                  , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        error "GBCMSRS_MERGE module does not support Conda. Please use Docker / Singularity instead."
    }
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def input_args = [types, mafs].transpose().collect { type, maf -> "--input ${type}:${maf}" }.join(' ')
    """
    gbcms merge \\
        ${input_args} \\
        --output ${prefix}.merged.maf \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gbcms: \$(gbcms --version | sed 's/^gbcms //')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.merged.maf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gbcms: 6.3.0
    END_VERSIONS
    """
}
