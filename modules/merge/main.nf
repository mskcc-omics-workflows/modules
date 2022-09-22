process MERGE {
    tag "FASTQ_MRG_$meta.id"
    label 'process_low'

    if (params.enable_conda) {
        exit 1, "Conda environments cannot be used when using merge. Please use docker or singularity containers."
    }
    container "mpathdms/merge:0.1.0"

    input:
    tuple val(meta), path(fastq_1), path(fastq_2)

    output:
    tuple val(meta), path("*_R*_mrg.fastq.gz")      ,emit: mrg_fq
    path "versions.yml"                             ,emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    zcat \\
    ${fastq_1} \\
    ${fastq_2} \\
    | \\
    gzip > ${meta.sample_name}_L000_R${meta.read}_mrg.fastq.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        merge: \$(echo \$(gzip --version 2>&1) | sed 's/^.*gzip //' ))
    END_VERSIONS
    """
}
