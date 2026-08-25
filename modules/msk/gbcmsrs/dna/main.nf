process GBCMSRS_DNA {
    tag "$meta.id"
    label 'process_medium'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'ghcr.io/msk-access/gbcms:6.3.0':
        'ghcr.io/msk-access/gbcms:6.3.0' }"
    containerOptions { workflow.containerEngine in ['docker', 'podman'] ? "--entrypoint ''" : '' }

    input:
    tuple val(meta), path(variants), path(bams), path(bais)
    path fasta
    path fasta_fai

    output:
    tuple val(meta), path("gbcms_out/*.{vcf,maf}"), emit: variant_file
    path "versions.yml"                            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        error "GBCMSRS_DNA module does not support Conda. Please use Docker / Singularity instead."
    }
    def args = task.ext.args ?: ''
    def bam_args = bams.collect { "--bam ${it}" }.join(' ')
    """
    gbcms dna \\
        --variants ${variants} \\
        ${bam_args} \\
        --fasta ${fasta} \\
        --output-dir gbcms_out \\
        --threads ${task.cpus} \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gbcms: \$(gbcms --version | sed 's/^gbcms //')
    END_VERSIONS
    """

    stub:
    """
    mkdir -p gbcms_out
    touch gbcms_out/${variants.baseName}.vcf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gbcms: 6.3.0
    END_VERSIONS
    """
}
