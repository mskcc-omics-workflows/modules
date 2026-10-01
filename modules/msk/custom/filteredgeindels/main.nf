process CUSTOM_FILTEREDGEINDELS {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/e9/e994bf4eb3731150511a14f5706b7bdfd64df1b6d40898fff334286c027e0859/data'
        : 'community.wave.seqera.io/library/htslib_samtools:1.24--d697cfb9dce007cd'}"

    input:
    tuple val(meta), path(bam), path(bai)

    output:
    tuple val(meta), path("${prefix}.bam")                   , emit: bam
    tuple val(meta), path("${prefix}.bam.bai")               , emit: bai
    tuple val(meta), path("${prefix}.edge_indel_qnames.txt") , emit: qnames
    tuple val(meta), path("${prefix}.edge_indel_counts.tsv") , emit: counts
    path "versions.yml"                                      , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix   = task.ext.prefix ?: "${meta.id}"
    if ("${prefix}.bam" == "${bam}") error "Input and output names are the same, set prefix in module configuration to disambiguate!"
    // Flag reads whose first or last two CIGAR operations are ID, DI, SI or SD: valid SAM, but Manta
    // cannot process them (e.g. ABRA2 output such as 92M22D8I). Same rule as Illumina/manta PR #288,
    // which fixes manta issues #137 and #184 but was never merged. Every record of a flagged read name
    // (both mates, secondary, supplementary) is dropped so no orphaned mates remain.
    def edge_indel_expr = 'cigar =~ "^[0-9]+(I[0-9]+D|D[0-9]+I|S[0-9]+[ID])" || cigar =~ "(I[0-9]+D|D[0-9]+I|[ID][0-9]+S)$"'
    """
    set -o pipefail
    samtools view -@ ${task.cpus} -e '${edge_indel_expr}' ${bam} | cut -f1 > flagged_records.txt
    sort -u flagged_records.txt > ${prefix}.edge_indel_qnames.txt

    flagged_records=\$(wc -l < flagged_records.txt | tr -d ' ')
    flagged_pairs=\$(wc -l < ${prefix}.edge_indel_qnames.txt | tr -d ' ')
    primary_in=\$(samtools view -@ ${task.cpus} -c -F 0x900 ${bam})

    samtools view -@ ${task.cpus} -b ${args} -N ^${prefix}.edge_indel_qnames.txt -o ${prefix}.bam ${bam}
    samtools index -@ ${task.cpus} ${prefix}.bam
    primary_out=\$(samtools view -@ ${task.cpus} -c -F 0x900 ${prefix}.bam)

    printf 'sample\\tflagged_records\\tflagged_pairs\\tprimary_reads_in\\tprimary_reads_out\\n%s\\t%s\\t%s\\t%s\\t%s\\n' \\
        "${meta.id}" "\$flagged_records" "\$flagged_pairs" "\$primary_in" "\$primary_out" \\
        > ${prefix}.edge_indel_counts.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """

    stub:
    prefix = task.ext.prefix ?: "${meta.id}"
    if ("${prefix}.bam" == "${bam}") error "Input and output names are the same, set prefix in module configuration to disambiguate!"
    """
    touch ${prefix}.bam
    touch ${prefix}.bam.bai
    touch ${prefix}.edge_indel_qnames.txt
    printf 'sample\\tflagged_records\\tflagged_pairs\\tprimary_reads_in\\tprimary_reads_out\\n' > ${prefix}.edge_indel_counts.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}
