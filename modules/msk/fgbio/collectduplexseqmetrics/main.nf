// TODO nf-core: If in doubt look at other nf-core/modules to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/modules/nf-core/
//               You can also ask for help via your pull request or on the #modules channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core: A module file SHOULD only define input and output files as command-line parameters.
//               All other parameters MUST be provided using the "task.ext" directive, see here:
//               https://www.nextflow.io/docs/latest/process.html#ext
//               where "task.ext" is a string.
//               Any parameters that need to be evaluated in the context of a particular sample
//               e.g. single-end/paired-end data MUST also be defined and evaluated appropriately.
// TODO nf-core: Software that can be piped together SHOULD be added to separate module files
//               unless there is a run-time, storage advantage in implementing in this way
//               e.g. it's ok to have a single module for bwa to output BAM instead of SAM:
//                 bwa mem | samtools view -B -T ref.fasta
// TODO nf-core: Optional inputs are not currently supported by Nextflow. However, using an empty
//               list (`[]`) instead of a file can be used to work around this issue.

process FGBIO_COLLECTDUPLEXSEQMETRICS {
    tag "$meta.id"
    label 'process_medium'

    // TODO nf-core: See section in main README for further information regarding finding and adding container addresses to the section below.
    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker pull ghcr.io/msk-access/fgbio:1.2.0':
        'docker pull ghcr.io/msk-access/fgbio:1.2.0' }"

    input:
    tuple val(meta) , path(bam), path(bai), path(interval_list)

    output:
    tuple val(meta), path("${prefix}.family_sizes.txt"),            emit: family_sizes
    tuple val(meta), path("${prefix}.duplex_family_sizes.txt"),     emit: duplex_family_sizes
    tuple val(meta), path("${prefix}.duplex_yield_metrics.txt"),    emit: duplex_yield_metrics
    tuple val(meta), path("${prefix}.umi_counts.txt"),              emit: umi_counts
    tuple val(meta), path("${prefix}.duplex_umi_counts.txt"),       emit: duplex_umi_counts
    path "versions.yml",                                            emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}_collapsed_grouped"


    """
    fgbio CollectDuplexSeqMetrics\\
        -@ $task.cpus \\
        -i $bam \\
        -o ${prefix} \\
        -l $interval_list \\
        --duplex-umi-counts true \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fgbio: \$(fgbio --version)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}_collapsed_grouped"
    // TODO nf-core: A stub section should mimic the execution of the original module as best as possible
    //               Have a look at the following examples:
    //               Simple example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bcftools/annotate/main.nf#L47-L63
    //               Complex example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bedtools/split/main.nf#L38-L54
    """
    
    touch ${prefix}.family_sizes.txt
    touch ${prefix}.duplex_family_sizes.txt
    touch ${prefix}.duplex_yield_metrics.txt
    touch ${prefix}.umi_counts.txt
    touch ${prefix}.duplex_umi_counts.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fgbio: \$(fgbio --version)
    END_VERSIONS

    """
}
