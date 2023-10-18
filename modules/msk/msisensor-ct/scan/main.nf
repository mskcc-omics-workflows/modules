process MSISENSOR_CT_SCAN {
    tag "$meta.id"
    label 'process_low'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        ghcr.io/msk-access/msisensor-ct:1.0 }"

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("*.list"), emit: list
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    msisensor-ct \\
        scan \\
        -d $fasta \\
        -o ${prefix}.msisensor_scan.list \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        msisensor-ct: \$(msisensor-ct 2>&1 | sed -nE 's/Version:\\sv([0-9]\\.[0-9])/\\1/ p')
    END_VERSIONS
    """
    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    echo stub > '${prefix}.msisensor_scan.list'
    echo "${task.process}:" > versions.yml
    echo ' msisensor-ct: 1.0' >> versions.yml

    """
}
