process NEOANTIGENEDITING_ALIGNTOIEDB {
    tag "$meta.id"
    label 'process_medium'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/neoantigenediting:1.2':
        'docker.io/mskcc/neoantigenediting:1.2' }"

    input:
    tuple val(meta),  path(patient_data)
    path(iedb_fasta)

    output:
    tuple val(meta), path("iedb_alignments_*.txt")             , emit: iedb_alignment
    path "versions.yml"                                        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    python3 /usr/bin/align_neoantigens_to_IEDB.py \\
        --fasta ${iedb_fasta} \\
        --input ${patient_data}
    


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        neoantigenEditing: \$NEOANTIGEN_EDITING_TAG
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """

    touch iedb_alignments_example.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        neoantigenEditing: \$NEOANTIGEN_EDITING_TAG
    END_VERSIONS
    """
}
