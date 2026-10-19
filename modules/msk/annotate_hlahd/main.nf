process ANNOTATE_HLAHD {
    tag "$meta.id"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://ghcr.io/mskcc-omics-workflows/hlahd-tools:1.0.1':
        'ghcr.io/mskcc-omics-workflows/hlahd-tools:1.0.1' }"

    input:
    tuple val(meta), path(result_dir)
    path pgroup_file

    output:
    tuple val(meta), path("${prefix}_annotated.tsv"), emit: tsv
    tuple val(meta), path("${prefix}_report.html"),   emit: report, optional: true
    path "versions.yml",                              emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix   = task.ext.prefix ?: "${meta.id}"
    """
    annotate_hlahd \\
        --result_dir ${result_dir} \\
        --sample ${prefix} \\
        --pgroup_file ${pgroup_file} \\
        --outdir . \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3 --version | sed 's/Python //')
        hla-annotate: \$(annotate_hlahd --version | sed 's/annotate_hlahd //')
    END_VERSIONS
    """

    stub:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    echo -e "sample\\tlocus\\tallele\\tallele_position\\tresolution\\tp_group\\tp_group_found\\tmultiple_best_pairs\\thas_ambiguous_pair\\tambiguous_alleles\\test_mismatch\\test_mismatch_detail\\texon2_depth\\texon2_incomp\\texon2_incomplete\\texon3_depth\\texon3_incomp\\texon3_incomplete\\tincomplete_bp\\tincomplete_coverage" > ${prefix}_annotated.tsv
    echo "<html><body>stub report</body></html>" > ${prefix}_report.html

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: 3.11
        hla-annotate: 1.0.1
    END_VERSIONS
    """
}
