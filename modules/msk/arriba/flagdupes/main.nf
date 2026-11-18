process ARRIBA_FLAGDUPES {
    tag "$meta.id"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/32/32d8754ef9bb101ff4296e7b3e3b5ecfc06bd492aaf3b0c84ecf8074d735d57a/data':
        'community.wave.seqera.io/library/gawk_r-base_r-data.table:b8be003a019a43d7' }"

    input:
    tuple val(meta), path(fusions), path(fusions_discarded)
    tuple val(meta2), path(gtf)
    tuple val(meta3), path(gene_rules)

    output:
    tuple val(meta), path("${prefix}.ptd_kdd.tsv")        , emit: tsv
    tuple val(meta), path("${prefix}.ptd_kdd.flagged.tsv"), emit: flagged
    path "versions.yml"                                    , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args           = task.ext.args ?: ''
    prefix             = task.ext.prefix ?: "${meta.id}"
    // With an Arriba fusions.discarded.tsv, also evaluate its same-gene target rows.
    def discarded_args = fusions_discarded ? "--include_discarded --discarded ${fusions_discarded}" : ''
    def out_names      = ["${prefix}.ptd_kdd.tsv", "${prefix}.ptd_kdd.flagged.tsv"]*.toString()
    if ([fusions, fusions_discarded].any { it && it.name in out_names }) {
        error "Input and output names are the same, set prefix in module configuration to disambiguate!"
    }
    """
    flag_ptd_kdd_itd_arriba.R \\
        --input ${fusions} \\
        --gtf ${gtf} \\
        --rules ${gene_rules} \\
        --output ${prefix}.ptd_kdd.tsv \\
        ${discarded_args} \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        flag_ptd_kdd_itd_arriba: \$(flag_ptd_kdd_itd_arriba.R --version | sed 's/.* //')
        r-base: \$(Rscript -e 'cat(as.character(getRversion()))')
        r-data.table: \$(Rscript -e 'cat(as.character(packageVersion("data.table")))')
    END_VERSIONS
    """

    stub:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.ptd_kdd.tsv
    touch ${prefix}.ptd_kdd.flagged.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        flag_ptd_kdd_itd_arriba: \$(flag_ptd_kdd_itd_arriba.R --version | sed 's/.* //')
        r-base: \$(Rscript -e 'cat(as.character(getRversion()))')
        r-data.table: \$(Rscript -e 'cat(as.character(packageVersion("data.table")))')
    END_VERSIONS
    """
}
