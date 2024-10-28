process MUTECT2 {
    tag "$meta.id"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'ghcr.io/broadinstitute/gatk:79faa25a14645d585ed3fcfab63fac4e8bbb15d2':
        'ghcr.io/broadinstitute/gatk:79faa25a14645d585ed3fcfab63fac4e8bbb15d2' }"

    input:
    tuple val(meta), path(case_bam), path(control_bam), path(case_bai), path(control_bai)
    tuple path(bed_file), path(fasta_file), path(fasta_index_file), path(fasta_dict_file)

    output:
    tuple val(meta), path("*.mutect2.vcf"), emit: mutect2_vcf

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def case_sample_name = task.ext.prefix ?: "${meta.case_id}"
    def control_sample_name = task.ext.prefix ?: "${meta.control_id}"
    def bed_file = bed_file ? "--intervals ${bed_file}" : ''


    """
    gatk "Mutect2" \\
    -R ${fasta_file} \\
    -I ${tumor_bam} \\
    -I ${control_bam} \\
    -tumor ${case_sample_name} \\
    -normal ${control_sample_name} \\
    ${args} \\
    --output ${meta.id}.mutect2.vcf

    """

    stub:
    """
    touch ${meta.id}.mutect2.vcf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gatk "Mutect2": \$(gatk "Mutect2" --version | sed -e "s/gatk "Mutect2" v//g")
    END_VERSIONS
    """
}
