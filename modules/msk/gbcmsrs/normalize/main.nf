process GBCMSRS_NORMALIZE {
    tag "$meta.id"
    label 'process_single'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'ghcr.io/msk-access/gbcms:6.3.0':
        'ghcr.io/msk-access/gbcms:6.3.0' }"

    containerOptions { workflow.containerEngine in ['docker', 'podman'] ? "--entrypoint ''" : '' }

    input:
    tuple val(meta), path(variants)
    path fasta
    path fasta_fai

    output:
    tuple val(meta), path("*.normalized.tsv"), emit: normalized
    path "versions.yml"                      , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        error "GBCMSRS_NORMALIZE module does not support Conda. Please use Docker / Singularity instead."
    }
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    gbcms normalize \\
        --variants ${variants} \\
        --fasta ${fasta} \\
        --output ${prefix}.normalized.tsv \\
        --threads ${task.cpus} \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gbcms: \$(gbcms --version | sed 's/^gbcms //')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.normalized.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gbcms: \$(echo "${task.container}" | sed 's/.*://')
    END_VERSIONS
    """
}
