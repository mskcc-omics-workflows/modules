process SALMON_INDEX {
    tag "$transcript_fasta"
    label "process_medium"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/salmon:0.14.0' :
        'docker.io/mskcc/salmon:0.14.0' }"

    input:
    path transcriptome_fasta

    output:
    path "salmon"      , emit: index
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def threads = task.cpus * 2
    """
    salmon \\
        index \\
        --threads $threads \\
        -t $transcriptome_fasta \\
        ${args} \\
        -i salmon

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        salmon: \$(echo \$(salmon --version) | sed -e "s/salmon //g")
    END_VERSIONS
    """

    stub:
    """
    mkdir salmon
    touch salmon/hash.bin
    touch salmon/header.json
    touch salmon/indexing.log
    touch salmon/quasi_index.log
    touch salmon/refInfo.json
    touch salmon/rsd.bin
    touch salmon/sa.bin
    touch salmon/txpInfo.bi
    touch salmon/versionInfo.json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        salmon: \$(echo \$(salmon --version) | sed -e "s/salmon //g")
    END_VERSIONS
    """
}
