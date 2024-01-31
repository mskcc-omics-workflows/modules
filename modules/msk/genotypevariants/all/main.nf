process GENOTYPEVARIANTS_ALL {
    tag "$meta.id"
    label 'process_single'


    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'ghcr.io/msk-access/genotype_variants:sha-303d0244':
        'ghcr.io/msk-access/genotype_variants:sha-303d0244' }"

    input:
    tuple val(meta), path(bam_standard), path(bai_standard), path(bam_duplex), path(bai_duplex), path(bam_simplex), path(bai_simplex)
    path(maf)
    path(fasta)
    path(fai)

    output:
    tuple val(meta), path("*.maf"), emit: maf
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def sample = task.ext.prefix ?: "${meta.id}"
    def patient = "${meta.patient}"
    def bams_standard = bam_standard ?"-b $bam_standard" : ''
    def bam_liquid = (bam_duplex && bam_simplex) ? "-d $bam_duplex -s $bam_simplex" : ''
    // TODO nf-core: If the tool supports multi-threading then you MUST provide the appropriate parameter
    //               using the Nextflow "task" variable e.g. "--threads $task.cpus"
    """
    genotype_variants small_variants all \\
    -i ${maf} \\
    -r ${fasta} \\
    -g /usr/local/bin/GetBaseCountsMultiSample \\
    -p ${patient} \\
    $bams_standard \\
    $bam_liquid \\
    -si ${sample} $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        genotypevariants: \$(genotype_variants --version)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def sample = "${meta.sample}"
    def patient = "${meta.patient}"
    // TODO nf-core: A stub section should mimic the execution of the original module as best as possible
    //               Have a look at the following examples:
    //               Simple example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bcftools/annotate/main.nf#L47-L63
    //               Complex example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bedtools/split/main.nf#L38-L54
    """
    touch ${prefix}.maf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        genotypevariants: \$(genotype_variants --version)
    END_VERSIONS
    """
}
