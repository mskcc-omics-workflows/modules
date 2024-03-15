process vcf2maf {
    tag "$meta.id" //sampleid
    label 'process_low' //resource requirements
    conda "${moduleDir}/environment.yml"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'ghcr.io/msk-access/snpsift:5.0':
        'ghcr.io/msk-access/snpsift:5.0' }"

    input:
    tuple val(meta), path(input_vcf),path(annotate_vcf)
    // keep adding the variables here for the tool.
    output:
    // Named file extensions MUST be emitted for ALL output channels
    tuple val(meta), path("*.vcf"), emit: vcf

    path "versions.yml"           , emit: versions
    
    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args ?: ''
    // customized arguments - value goes in the nextflow.config
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
   java -jar /snpEff/SnpSift.jar annotate  ${annotate_vcf} ${input_vcf}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        SnpSift: \$(echo \$(java -jar /snpEff/SnpSift.jar --help'))
    END_VERSIONS
    """
    // call variables with ${x}
    stub:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    echo "stub test" >> ${prefix}.maf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        SnpSift: \$(echo \$(java -jar /snpEff/SnpSift.jar --help'))
    END_VERSIONS
    """
}
