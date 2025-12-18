process CUSTOM_FINGERPRINTCONTAMINATION {
    tag "$meta.id"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        //'oras://community.wave.seqera.io/library/numpy_pandas:1f8cb70bfdb82865':
        'docker://community.wave.seqera.io/library/numpy_pandas:f27ed83387b3c038':
        'community.wave.seqera.io/library/numpy_pandas:f27ed83387b3c038' }"

    input:
    tuple val(meta), path(fp_tumor), path(fp_normal)

    output:
    tuple val(meta), path("*.contamination.tsv")                                                                           , emit: contamination_tsv
    tuple val("${task.process}"), val('calculate_contamination.py'), eval('calculate_contamination.py -v | cut -f 2 -d" "'), emit: versions_fingerprintvcfparser, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    calculate_contamination.py \\
        -t ${fp_tumor} \\
        -n ${fp_normal ?: fp_tumor} \\
        -o ${prefix}.contamination.tsv \\
        ${args}

    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.contamination.tsv

    """
}
