process ONCOKB_MAFANNOTATOR {
    tag "$meta.id"
    label 'process_single'
    cache false
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://orgeraj/oncokbtst:1.2':
        'docker.io/orgeraj/oncokbtst:1.2' }"

    input:
    tuple val(meta),  path(inputMaf)

    output:
    tuple val(meta), path("*oncokb.maf"),     emit: oncokb_maf
    
    path "versions.yml",                      emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:

    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    python3 /usr/bin/oncokb/MafAnnotator.py \
    -i ${inputMaf} \
    -o ${prefix}.oncokb.maf \
    $args


    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
        mkdir ${prefix}_out
        touch ${prefix}.oncokb.maf

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            MafAnnotator: \$(echo \$(MafAnnotator.py -v))
        END_VERSIONS
    """
}
