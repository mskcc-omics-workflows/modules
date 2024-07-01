process SALMON_QUANT {
    tag "$meta.id"
    label "process_medium"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/salmon:0.14.0' :
        'docker.io/mskcc/salmon:0.14.0' }"


    input:
    tuple val(meta), path(reads)
    path  index

    output:
    tuple val(meta), path("${meta.id}.salmon.quant")    , emit: results
    tuple val(meta), path("${meta.id}.quant.sf")        , emit: quant
    path  "versions.yml"                                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args     = task.ext.args   ?: ''
    def prefix   = task.ext.prefix ?: "${meta.id}"
    def threads  = task.cpus * 2

    """
    salmon quant \\
        --index ${index} \\
        --seqBias \\
        --gcBias \\
        --libType A \\
        --unmatedReads ${reads} \\
        --validateMappings \\
        -o ${prefix}.salmon.quant \\
        --threads ${threads}

    cp ${prefix}.salmon.quant/quant.sf ${prefix}.quant.sf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        salmon: \$(echo \$(salmon --version) | sed -e "s/salmon //g")
    END_VERSIONS
    """

    stub:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir ${prefix}.salmon.quant
    touch ${prefix}.quant.sf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        salmon: \$(echo \$(salmon --version) | sed -e "s/salmon //g")
    END_VERSIONS
    """
}
