process NEOANTIGENEDITING_ALIGNTOIEDB {
    tag "$meta.id"
    label 'process_medium'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://ghcr.io/mskcc-omics-workflows/neoantigen-editing:1.1':
        'ghcr.io/mskcc-omics-workflows/neoantigen-editing:1.1' }"

    input:
    tuple val(meta),  path(sample_file)
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
    align_neoantigens_to_IEDB.py \\
        --fasta ${iedb_fasta} \\
        --input ${sample_file} \\
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

    touch iedb_alignments_example.txt

    cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    neoantigenEditing: \$NEOANTIGEN_EDITING_TAG
	END_VERSIONS
    """
}
