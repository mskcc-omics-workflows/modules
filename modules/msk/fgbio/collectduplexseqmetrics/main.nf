process FGBIO_COLLECTDUPLEXSEQMETRICS {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'ghcr.io/msk-access/fgbio:1.2.0':
        'ghcr.io/msk-access/fgbio:1.2.0' }"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("${prefix}.family_sizes.txt"),            emit: family_sizes
    tuple val(meta), path("${prefix}.duplex_family_sizes.txt"),     emit: duplex_family_sizes
    tuple val(meta), path("${prefix}.duplex_yield_metrics.txt"),    emit: duplex_yield_metrics
    tuple val(meta), path("${prefix}.umi_counts.txt"),              emit: umi_counts
    tuple val(meta), path("${prefix}.duplex_umi_counts.txt"),       emit: duplex_umi_counts
    path "versions.yml",                                            emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}_collapsed_grouped"


    """
    fgbio CollectDuplexSeqMetrics\\
        -i $bam \\
        -o ${prefix} \\
        --duplex-umi-counts true \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fgbio: \$(fgbio CollectDuplexSeqMetrics --version 2>&1 | grep -o 'Version:.*' | cut -f2- -d: | xargs)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}_collapsed_grouped"
    """
    
    touch ${prefix}.family_sizes.txt
    touch ${prefix}.duplex_family_sizes.txt
    touch ${prefix}.duplex_yield_metrics.txt
    touch ${prefix}.umi_counts.txt
    touch ${prefix}.duplex_umi_counts.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fgbio: \$(fgbio CollectDuplexSeqMetrics --version 2>&1 | grep -o 'Version:.*' | cut -f2- -d: | xargs)
    END_VERSIONS

    """
}
