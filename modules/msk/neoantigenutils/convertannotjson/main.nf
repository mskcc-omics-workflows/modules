process NEOANTIGENUTILS_CONVERTANNOTJSON {
    tag "$meta.id"
    label 'process_single'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/neoantigen-utils-base:1.0.0':
        'docker.io/mskcc/neoantigen-utils-base:1.0.0' }"

    input:
    tuple val(meta),  path(annotatedJSON)

    output:
    tuple val(meta), path("*.tsv"),              emit: neoantigenTSV
    path "versions.yml",                         emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
        convertannotjson.py \
            --json_file ${annotatedJSON} \
            --output_file ${prefix}_neoantigens.tsv

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            convertannotjson: \$(echo \$(convertannotjson.py -v))
        END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """

        touch ${prefix}_neoantigens.tsv
        touch test.tsv

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            convertannotjson: \$(echo \$(convertannotjson.py -v))
        END_VERSIONS
    """
}
