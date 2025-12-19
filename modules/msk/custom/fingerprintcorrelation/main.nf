process CUSTOM_FINGERPRINTCORRELATION {
    tag {'$prefix'}
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://community.wave.seqera.io/library/r-argparse_r-data.table_r-dplyr_r-ggforce_pruned:5c045bc9fea1dbd5':
        'community.wave.seqera.io/library/r-argparse_r-data.table_r-dplyr_r-ggforce_pruned:5c045bc9fea1dbd5' } "
        // 'oras://community.wave.seqera.io/library/r-argparse_r-data.table_r-dplyr_r-ggforce_pruned:8211a2010a4712ea':

    input:
    tuple val(meta), path(combined_fp_tsv)

    output:
    tuple val(meta), path("*_gbcm_sample-to-sample4.pdf")                          , emit: heatmap_pdf
    tuple val(meta), path("*_interactive4.html")                                   , emit: heatmap_html
    tuple val(meta), path("*_observations.tab")                                    , emit: observations_tab
    tuple val(meta), path("*_correlations.tab")                                    , emit: correlations_tab
    tuple val("${task.process}"), val('plot_gbcm.R'), val("0.1.0"), topic: versions, emit: versions_fingerprintcorrelation

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = meta.id ?: "batch"
    """
    plot_gbcm.R \\
        -t ${combined_fp_tsv} \\
        -o ./ \\
        -p ${prefix}
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = meta.id ?: "batch"
    """
    touch ${prefix}_gbcm_sample-to-sample4.pdf
    touch ${prefix}_interactive4.html
    touch ${prefix}_observations.tab
    touch ${prefix}_correlations.tab
    """
}
