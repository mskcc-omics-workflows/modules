process PHYLOWGS_CREATEINPUT {
    tag "$meta.id"
    label 'process_low'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/phylowgs:v1.4-msk':
        'docker.io/mskcc/phylowgs:v1.4-msk' }"

    input:
    tuple val(meta), path(cnv) 
    tuple val(meta1), path(unfilteredmaf)

    output:
    tuple val(meta), path("cnv_data.txt"), path("ssm_data.txt"), emit: phylowgsinput
    path "versions.yml"                                        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """ 
    python2 \\
        /usr/bin/parser/create_phylowgs_inputs.py \\
        --cnvs S1=${cnv} \\
        ${args} \\
        --vcf-type S1=maf S1=${unfilteredmaf}
    

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        phylowgs: \$PHYLOWGS_TAG
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch cnv_data.txt
    touch ssm_data.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        phylowgs: \$PHYLOWGS_TAG
    END_VERSIONS
    """
}
