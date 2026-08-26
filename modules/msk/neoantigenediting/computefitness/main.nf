process NEOANTIGENEDITING_COMPUTEFITNESS {
    tag "$meta.id"
    label 'process_medium'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://ghcr.io/mskcc-omics-workflows/neoantigen-editing:1.1':
        'ghcr.io/mskcc-omics-workflows/neoantigen-editing:1.1' }"

    input:
    tuple val(meta),  path(sample_file), path(alignment_file)

    output:
    tuple val(meta), path("*_annotated.json")               , emit: annotated_output
    path "versions.yml"                                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    compute_fitness.py \\
        --alignment ${alignment_file} \\
        --sample_file ${sample_file} \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    neoantigenEditing: \$NEOANTIGEN_EDITING_TAG
	END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """

    touch ${prefix}_annotated.json

    cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    neoantigenEditing: \$NEOANTIGEN_EDITING_TAG
	END_VERSIONS
    """
}
