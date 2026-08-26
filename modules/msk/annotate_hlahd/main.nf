process ANNOTATE_HLAHD {
    tag "$meta.id"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://ghcr.io/mskcc-omics-workflows/hlahd-tools:1.0.0':
        'ghcr.io/mskcc-omics-workflows/hlahd-tools:1.0.0' }"

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
    annotate_hlahd.py \\
        --result_dir ${result_dir} \\
        --sample ${prefix} \\
        --pgroup_file ${pgroup_file} \\
        --outdir . \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python3 --version | sed 's/Python //')
    END_VERSIONS
    """

    stub:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    echo -e "locus\\tallele1\\tallele2\\tp_group" > ${prefix}_annotated.tsv
    echo "<html><body>stub report</body></html>" > ${prefix}_report.html

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: 3.11
    END_VERSIONS
    """
}
