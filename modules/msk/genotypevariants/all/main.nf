process GENOTYPEVARIANTS_ALL {
    tag "$meta.id"
    label 'process_medium'


    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'ghcr.io/msk-access/genotype_variants:0.3.9':
        'ghcr.io/msk-access/genotype_variants:0.3.9' }"

    input:
    // [[patient:null, id:'sample'], standard.bam, standard.bam.bai, [], [], [], []]
    // or
    // [[patient:null, id:'sample'], [], [], duplex.bam, duplex.bam.bai, simplex.bam, simplex.bam.bai]
    tuple val(meta), path(bam_standard), path(bai_standard), path(bam_duplex), path(bai_duplex), path(bam_simplex), path(bai_simplex), path(maf)
    path(fasta)
    path(fai)

    output:
    tuple val(meta), path("*.maf"), emit: maf
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def sample = task.ext.prefix != null ? "-si ${task.ext.prefix}" : (meta.id != null ? "-si ${meta.id}" : "")
    def patient = meta.patient ?"-p ${meta.patient}": ''
    def bams_standard = bam_standard ?"-b $bam_standard" : ''
    def bam_liquid = (bam_duplex && bam_simplex) ? "-d $bam_duplex -s $bam_simplex" : ''

    """
    genotype_variants small_variants all \\
    -i ${maf} \\
    -r ${fasta} \\
    -g /usr/local/bin/GetBaseCountsMultiSample \\
    $patient \\
    $bams_standard \\
    $bam_liquid \\
    $sample \\
    -t $task.cpus \\
    $args

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

    """
    touch ${prefix}-DUPLEX_genotyped.maf
    touch ${prefix}-ORG-SIMPLEX-DUPLEX_genotyped.maf
    touch ${prefix}-SIMPLEX-DUPLEX_genotyped.maf
    touch ${prefix}-SIMPLEX_genotyped.maf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        genotypevariants: \$(genotype_variants --version)
    END_VERSIONS
    """
}
