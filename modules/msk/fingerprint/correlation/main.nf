process FINGERPRINT_CORRELATION {
    tag {"$prefix"}
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://community.wave.seqera.io/library/r-argparse_r-data.table_r-dplyr_r-ggforce_pruned:5c045bc9fea1dbd5':
        'community.wave.seqera.io/library/r-argparse_r-data.table_r-dplyr_r-ggforce_pruned:5c045bc9fea1dbd5' } "
        // 'oras://community.wave.seqera.io/library/r-argparse_r-data.table_r-dplyr_r-ggforce_pruned:8211a2010a4712ea':

    input:
    tuple val(meta), path(combined_fp_tsv)
    val(filter_term)

    output:
    tuple val(meta), path("*.pdf")                                                 , emit: heatmap_pdf
    tuple val(meta), path("*.html")                                                , emit: heatmap_html
    tuple val(meta), path("*_observations.tab")                                    , emit: observations_tab
    tuple val(meta), path("*_correlations.tab")                                    , emit: correlations_tab
    tuple val("${task.process}"), val('plot_gbcm.R'), val("0.1.0"), topic: versions, emit: versions_correlation

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = meta.id ?: "batch"
    def pool_arg = "-p ${meta.id ?: "batch"}"
    filter_args = (filter_term && filter_term != "") ? pool_arg + " -f" : pool_arg
    """
    export XDG_CACHE_HOME=$PWD/fontconfig-cache ; mkdir -p $XDG_CACHE_HOME

    plot_gbcm.R \\
        -t ${combined_fp_tsv} \\
        -o ./ \\
        ${filter_args} \\
        ${args}
    """

    stub:
    def args = task.ext.args ?: ''
    prefix = meta.id ?: "batch"
    """
    touch ${prefix}.pdf
    touch ${prefix}.html
    touch ${prefix}_observations.tab
    touch ${prefix}_correlations.tab
    """
}
