process GENOTYPEVARIANTS_ALL {
    tag "$meta.id"
    label 'process_single'


    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'ghcr.io/msk-access/genotype_variants:sha-60b7f8bc':
        'ghcr.io/msk-access/genotype_variants:sha-60b7f8bc' }"

    input:
    tuple val(meta), path(bam)
    tuple val(meta), path(maf)
    path  fasta
    path  fai

    output:
    tuple val(meta), path("*.maf"), emit: maf
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def sample = "${meta.sample}"
    def patient = "${meta.patient}"
    // TODO nf-core: If the tool supports multi-threading then you MUST provide the appropriate parameter
    //               using the Nextflow "task" variable e.g. "--threads $task.cpus"
    """
    genotype_variants small_variants all \\
        -i ${maf} \\ 
        -r ${fasta} \\
        -g /usr/local/bin/GetBaseCountsMultiSample \\
        -p ${patient} \\
        -b ${bam} \\
        -s ${sample} \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        genotypevariants: \$(genotype_variants --version)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // TODO nf-core: A stub section should mimic the execution of the original module as best as possible
    //               Have a look at the following examples:
    //               Simple example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bcftools/annotate/main.nf#L47-L63
    //               Complex example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bedtools/split/main.nf#L38-L54
    """
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        genotypevariants: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """
}
