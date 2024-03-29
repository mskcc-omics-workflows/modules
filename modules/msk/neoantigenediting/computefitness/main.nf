process NEOANTIGENEDITING_COMPUTEFITNESS {
    tag "$meta.id"
    label 'process_medium'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/neoantigenediting:1.2':
        'docker.io/mskcc/neoantigenediting:1.2' }"

    input:
    tuple val(meta),  path(patient_data), path(alignment_file)
    
    output:
    tuple val(meta), path("*_annotated.json")               , emit: annotated_output
    path "versions.yml"                                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    python3 /usr/bin/compute_fitness.py \\
        --alignment ${alignment_file} \\
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
    
    touch patient_data_annotated.json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        neoantigenEditing: \$NEOANTIGEN_EDITING_TAG
    END_VERSIONS
    """
}
