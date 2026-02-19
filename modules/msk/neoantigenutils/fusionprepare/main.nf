process NEOANTIGENUTILS_FUSIONPREPARE {
    tag "$meta.id"
    label 'process_single'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://ghcr.io/mskcc-omics-workflows/neoantigen-utils-base:1.4.0':
        'ghcr.io/mskcc-omics-workflows/neoantigen-utils-base:1.4.0' }"

    input:
    tuple val(meta), path(agfusion_dir)

    output:
    tuple val(meta), path("*.SV.MUT.fa"), emit: mut_fasta
    tuple val(meta), path("*.SV.WT.fa"),  emit: wt_fasta
    path "versions.yml",                  emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    prepare_fusion_fasta.py \\
        --agfusion_dir ${agfusion_dir} \\
        --output_prefix ${prefix} \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        prepare_fusion_fasta: \$(echo \$(prepare_fusion_fasta.py -v))
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.SV.MUT.fa
    touch ${prefix}.SV.WT.fa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        prepare_fusion_fasta: \$(echo \$(prepare_fusion_fasta.py -v))
    END_VERSIONS
    """
}
