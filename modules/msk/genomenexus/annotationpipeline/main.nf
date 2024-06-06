process GENOMENEXUS_ANNOTATIONPIPELINE {
    tag "$meta.id"
    label 'process_high'

    
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'ghcr.io/msk-access/genomenexus_annotation-pipeline:1.0.3':
        'ghcr.io/msk-access/genomenexus_annotation-pipeline:1.0.3' }"

    input:
    tuple val(meta), path(input_maf)

    output:
    tuple val(meta), path("*.maf"), emit: annotated_maf
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    java -jar /genome-nexus-annotation-pipeline/annotationPipeline/target/annotationPipeline.jar --filename ${input_maf} --output-filename ${meta.id}_annotated.maf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        genomenexus: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """
    
    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    
    """
    touch ${meta.id}_annotated.maf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        genomenexus: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """
}
