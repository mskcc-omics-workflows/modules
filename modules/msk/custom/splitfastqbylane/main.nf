process CUSTOM_SPLITFASTQBYLANE {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gawk:5.1.0':
        'biocontainers/gawk:5.1.0' }"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.split.fastq.gz"), emit: reads
    path "versions.yml"                      , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def read1 = [reads].flatten()[0]
    def read2 = [reads].flatten().size() > 1 ? reads[1] : null
    """
    split_lanes_awk.sh ${prefix} ${read1} ${read2 ?: ''}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gawk: \$(awk -Wversion | sed '1!d; s/.*Awk //; s/,.*//')
    END_VERSIONS
    """
    
    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch out.split.fastq
    gzip out.split.fastq
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gawk: \$(awk -Wversion | sed '1!d; s/.*Awk //; s/,.*//')
    END_VERSIONS
    """
}
