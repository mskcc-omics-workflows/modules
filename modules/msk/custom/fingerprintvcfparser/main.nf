process CUSTOM_FINGERPRINTVCFPARSER {
    tag "$meta.id"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pysam:0.23.0--py39hdd5828d_0':
        'biocontainers/pysam:0.23.0--py39hdd5828d_0' }"

    input:
    tuple val(meta), path(vcf)

    output:
    tuple val(meta), path("${prefix}.fp.tsv")                                                                          , emit: tsv
    tuple val("${task.process}"), val('parse_fingerprint_vcf.py'), eval('parse_fingerprint_vcf.py -v | cut -f 2 -d" "'), emit: versions_fingerprintvcfparser, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    parse_fingerprint_vcf.py \\
        --input ${vcf} \\
        --output ${prefix}.fp.tsv \\
        --samplename ${prefix} \\
        $args

    """

    stub:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    echo $args

    touch ${prefix}.fp.tsv

    """
}
