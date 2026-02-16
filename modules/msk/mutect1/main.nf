process MUTECT1 {
    tag "$meta.id"
    label 'process_low'
    shell '/bin/sh'


    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'ghcr.io/msk-access/mutect1:1.1.5':
        'ghcr.io/msk-access/mutect1:1.1.5' }"

    input:
    tuple val(meta), path(case_bam), path(control_bam), path(case_bai), path(control_bai)
    tuple path(bed_file), path(fasta_file), path(fasta_index_file), path(fasta_dict_file)

    output:

    tuple val(meta), path("*.mutect.vcf"), emit: mutect_vcf
    tuple val(meta), path("*.mutect.txt"), emit: standard_mutect_output

    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def case_sample_name = task.ext.prefix ?: "${meta.case_id}"
    def control_sample_name = task.ext.prefix ?: "${meta.control_id}"
    def bed_file = bed_file ? "--intervals ${bed_file}" : ''


    """
    java -Xmx28g -Xms256m -XX:-UseGCOverheadLimit -jar /opt/mutect/muTect-1.1.5.jar -T MuTect \
        ${args} \
        --input_file:tumor ${case_bam} \
        --input_file:normal ${control_bam} \
        --intervals ${bed_file} \
        --tumor_sample_name ${case_sample_name} \
        --reference_sequence ${fasta_file} \
        --normal_sample_name ${control_sample_name} \
        ${args2} \
        --out ${case_sample_name}.${control_sample_name}.mutect.txt \
        --vcf ${case_sample_name}.${control_sample_name}.mutect.vcf


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mutect1: \$(echo \$(java -jar /opt/mutect/muTect-1.1.5.jar --help) | grep -o 'The Genome Analysis Toolkit (GATK) v[0-9]\\.[0-9]\\-[0-9]' | sed 's/.* \\([v0-9.-]*\\)/\\1/')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def case_sample_name = task.ext.prefix ?: "${meta.case_id}"
    def control_sample_name = task.ext.prefix ?: "${meta.control_id}"
    def bed_file = bed_file ? "--intervals ${bed_file}" : ''

    """

    touch ${case_sample_name}.${control_sample_name}.mutect.txt
    touch ${case_sample_name}.${control_sample_name}.mutect.vcf
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mutect1: \$(echo \$(java -jar /opt/mutect/muTect-1.1.5.jar --help) | grep -o 'The Genome Analysis Toolkit (GATK) v[0-9]\\.[0-9]\\-[0-9]' | sed 's/.* \\([v0-9.-]*\\)/\\1/')
    END_VERSIONS
    """
}
