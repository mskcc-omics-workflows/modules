process POLYSOLVER {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://sachet/polysolver:v3':
        'docker.io/sachet/polysolver:v3' }"

    input:
    tuple val(meta), path(bam)
    val(includeFreq)
    val(build)
    val(format)
    val(insertCalc)

    output:
    tuple val(meta), path("*.hla.txt"), emit: hla
    path  "versions.yml"              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args              = task.ext.args ?: ''
    def prefix            = task.ext.prefix ?: "${meta.id}"
    def includeFreq_param = includeFreq ?: 1
    def insertCalc_param  = insertCalc ?: 0
    def build_param       = build ? (["GRCh37","hg19"].contains(build) ? "hg19" : "hg38") : "hg19"
    def format_param      = format ?: "STDFQ"
    """
    cp /home/polysolver/scripts/shell_call_hla_type .
    sed -i "171s/TMP_DIR=.*/TMP_DIR=nf-scratch/" shell_call_hla_type 
    bash shell_call_hla_type \\
        ${bam} \\
        Unknown \\
        ${includeFreq_param} \\
        ${build_param} \\
        ${format_param} \\
        ${insertCalc_param} \\
        ${prefix}

    mv ${prefix}/winners.hla.txt ${prefix}.hla.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        polysolver: v3
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.hla.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        polysolver: v3
    END_VERSIONS
    """
}
