process GENOMENEXUS_VCF2MAF {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'ghcr.io/msk-access/genomenexus:latest':
        'ghcr.io/msk-access/genomenexus:latest' }"

    input:
    tuple val(meta), path(vcf)

    output:
    tuple val(meta), path("vcf2maf_output/${meta.id}.maf"), emit: maf
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    

    """
    python3 /annotation-tools/vcf2maf.py -i ${vcf} ${args}
    

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
    vcf2maf.py v.1.0.3'
    END_VERSION
    """
    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """

    mkdir vcf2maf_output
    touch ${meta.id}.maf
    cp ${meta.id}.maf vcf2maf_output/
    


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
    vcf2maf.py v.1.0.3'
    END_VERSION
    """
}
