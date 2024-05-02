process PPFLAGFIXER {
    tag "$meta.id"
    label 'process_medium'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/facets-suite:2.0.9':
        'docker.io/mskcc/facets-suite:2.0.9' }"

    input:
    tuple val(meta), path(process_bam), path(process_bam_index)

    output:
    tuple val(meta), path("ppflag.*.bam")   , emit: ppflag_bam
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    /usr/bin/ppflag-fixer \
        ${args} \
        ${process_bam} \
        ppflag.${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        htslib: \$(bgzip --version | grep -oP '(?<=\\(htslib\\) ).*')
        r: \$(R --version | grep -oP '(?<=R version ).*(?=\\()')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    echo "stub test" >> ppflag.${prefix}.bam
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        htslib: \$(bgzip --version | grep -oP '(?<=\\(htslib\\) ).*')
        r: \$(R --version | grep -oP '(?<=R version ).*(?=\\()')
    END_VERSIONS
    """
}
