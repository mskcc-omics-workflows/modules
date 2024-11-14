process GENOMENEXUS_VCF2MAF {
    tag "$meta.id"
    label 'process_low'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'ghcr.io/msk-access/genomenexus:vcf2maf_lite':
        'ghcr.io/msk-access/genomenexus:vcf2maf_lite' }"

    input:
    tuple val(meta), path(vcf)

    output:
    tuple val(meta), path("vcf2maf_output/${meta.control_id}_${meta.case_id}_annotated.maf"), emit: maf
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    python3 /vcf2maf-lite/vcf2maf_lite.py -i ${vcf} ${args}
    echo '"${task.process}": vcf2maf_lite.py v.0.0.1' > versions.yml
    """
    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """

    mkdir vcf2maf_output
    touch ${meta.control_id}_${meta.case_id}_annotated.maf
    cp ${meta.control_id}_${meta.case_id}_annotated.maf vcf2maf_output/
    echo '"${task.process}": vcf2maf_lite.py v.0.0.1' > versions.yml
    """
}
