process ONCOKB_MAFANNOTATE {
    tag "$meta.id"
    label 'process_single'

    secret 'ONCOKB_TOKEN'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'ghcr.io/mskcc-omics-workflows/oncokb:3.4.1':
        'ghcr.io/mskcc-omics-workflows/oncokb:3.4.1' }"

    input:
    tuple val(meta),  path(inputMaf)

    output:
    tuple val(meta), path("*.oncokb.maf"),     emit: oncokb_maf
    path "versions.yml",                       emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:

    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    python3 /usr/bin/oncokb/MafAnnotator.py \
    -i ${inputMaf} \
    -o ${prefix}.oncokb.maf \
    -b ${ONCOKB_TOKEN}
    $args

    cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            MafAnnotator: \$(echo \$(MafAnnotator.py -v))
        END_VERSIONS
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
