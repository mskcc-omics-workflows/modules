process CUSTOM_FINGERPRINTMISLABELS {
    tag "$meta.id"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://community.wave.seqera.io/library/r-argparse_r-data.table_r-dplyr_r-plyr_r-tidyverse:8c0daffb3624cb66':
        'community.wave.seqera.io/library/r-argparse_r-data.table_r-dplyr_r-plyr_r-tidyverse:8c0daffb3624cb66' }"

    input:
    tuple val(meta), path(correlations_tab), path(observations_tab)
    path(sample_sheet)

    output:
    tuple val(meta), path("*_unexpected_match.pdf"),    emit: unexpected_match_pdf
    tuple val(meta), path("*_unexpected_match.txt"),    emit: unexpected_match_txt
    tuple val(meta), path("*_unexpected_mismatch.pdf"), emit: unexpected_mismatch_pdf
    tuple val(meta), path("*_unexpected_mismatch.txt"), emit: unexpected_mismatch_txt
    tuple val("${task.process}"), val('unexpected_match_mismatch.R'), val("0.1.0"), emit: versions_fingerprintmislabels, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args   = task.ext.args   ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    prefix = (prefix && prefix != "") ? prefix : "batch"
    """
    unexpected_match_mismatch.R \\
        -r ${prefix} \\
        -o ./ \\
        -i ${sample_sheet} \\
        -c ${correlations_tab} \\
        -n ${observations_tab} \\
        ${args}
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_unexpected_match.pdf
    touch ${prefix}_unexpected_match.txt
    touch ${prefix}_unexpected_mismatch.pdf
    touch ${prefix}_unexpected_mismatch.txt
    """
}
