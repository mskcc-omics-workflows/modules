process GBCMSRS_BUILDGTFCACHE {
    tag "${variants.name}"
    label 'process_single'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'ghcr.io/msk-access/gbcms:6.3.0':
        'ghcr.io/msk-access/gbcms:6.3.0' }"
    containerOptions { workflow.containerEngine in ['docker', 'podman'] ? "--entrypoint ''" : '' }

    input:
    path variants
    path gtf

    output:
    path "gbcms_gtf_cache", emit: cache_dir
    path "versions.yml"   , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        error "GBCMSRS_BUILDGTFCACHE module does not support Conda. Please use Docker / Singularity instead."
    }
    def args = task.ext.args ?: ''
    """
    mkdir -p gbcms_gtf_cache
    gbcms build-gtf-cache \\
        --gtf ${gtf} \\
        --variants ${variants} \\
        --gtf-cache-dir gbcms_gtf_cache \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gbcms: \$(gbcms --version | sed 's/^gbcms //')
    END_VERSIONS
    """

    stub:
    """
    mkdir -p gbcms_gtf_cache
    touch gbcms_gtf_cache/gbcms-gtf-stub.idx

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gbcms: \$(echo "${task.container}" | sed 's/.*://')
    END_VERSIONS
    """
}
