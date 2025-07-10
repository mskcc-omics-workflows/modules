process CALCULATENOISE {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://ghcr.io/mikefeixu/sequence_qc:0.2.6' :
        'ghcr.io/mikefeixu/sequence_qc:0.2.6' }"

    input:
    tuple val(meta) , path(bam), path(bai), path(target_intervals)
    path(fasta)
    path(fai)

    output:
    tuple val(meta), path("${prefix}_acgt.tsv"),            emit: acgt
    tuple val(meta), path("${prefix}_by_substitution.tsv"), emit: substitution
    tuple val(meta), path("${prefix}_by_tlen.tsv"),         emit: bytlen
    tuple val(meta), path("${prefix}_del.tsv"),             emit: del
    tuple val(meta), path("${prefix}_n.tsv"),               emit: count
    tuple val(meta), path("${prefix}_positions.tsv"),       emit: positions
    tuple val(meta), path("${prefix}.html"),                emit: html
    tuple val(meta), path("${meta.id}_pileup.tsv"),         emit: pileup
    path "versions.yml",                                    emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}_noise"
    def reference_arg = fasta ? "--ref_fasta ${fasta}" : ''

    // Memory setting (optional)
    def avail_mem = 3000  // default in MB
    if (!task.memory) {
        log.info '[calculate_noise] Available memory not known - defaulting to 3GB. Specify process.memory to change this.'
    } else {
        avail_mem = (task.memory.mega * 0.8).intValue()
    }

    """
    sed -i 's/\r\$//' $target_intervals
    calculate_noise \\
        ${reference_arg} \\
        --bam_file $bam \\
        --bed_file $target_intervals \\
        --sample_id ${meta.id} \\
        --threshold 0.01 \\
        --truncate 1 \\
        --min_mapq 10 \\
        --min_basq 10 \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        calculatenoise: \$(calculate_noise --help 2>/dev/null || echo "Usage")
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}_noise"
    """
    touch ${prefix}_acgt.tsv
    touch ${prefix}_by_substitution.tsv
    touch ${prefix}_by_tlen.tsv
    touch ${prefix}_del.tsv
    touch ${prefix}_n.tsv
    touch ${prefix}_positions.tsv
    touch ${prefix}.html
    touch ${meta.id}_pileup.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        calculatenoise: \$(calculate_noise --help 2>/dev/null || echo "Usage")
    END_VERSIONS
    """
}
