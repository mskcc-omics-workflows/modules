process NEOANTIGENUTILS_RNAANNOTATE {
    tag "$meta.id"
    label 'process_single'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://ghcr.io/mskcc-omics-workflows/neoantigen-utils-base:1.4.0':
        'ghcr.io/mskcc-omics-workflows/neoantigen-utils-base:1.4.0' }"

    input:
    tuple val(meta),  path(neoantigen_tsv)
    tuple val(meta2), path(maf)
    tuple val(meta3), path(kallisto_abundance)
    path(gtf)

    output:
    tuple val(meta), path("*_rna_annotated.tsv"),  emit: annotated_tsv
    tuple val(meta), path("*_rna_report.tsv"),     emit: rna_report
    path "versions.yml",                           emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def kallisto_arg = kallisto_abundance ? "--kallisto_abundance ${kallisto_abundance} --gtf ${gtf}" : ""

    """
    annotate_rna.py \\
        --neoantigen_tsv ${neoantigen_tsv} \\
        --maf ${maf} \\
        ${kallisto_arg} \\
        --output_annotated ${prefix}_rna_annotated.tsv \\
        --output_report ${prefix}_rna_report.tsv \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        annotate_rna: \$(echo \$(annotate_rna.py -v))
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_rna_annotated.tsv
    touch ${prefix}_rna_report.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        annotate_rna: \$(echo \$(annotate_rna.py -v))
    END_VERSIONS
    """
}
