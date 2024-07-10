process PVMAF_CONCAT {
    tag "$meta.id"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'ghcr.io/msk-access/postprocessing_variant_calls:0.3.0':
        'ghcr.io/msk-access/postprocessing_variant_calls:0.3.0' }"

    input:
    tuple val(meta), path(maf_files) // [ id:'sample1', patient:'patient1' ], [maf_1, ... maf_n]


    output:
    tuple val(meta), path("*.maf"), emit: maf
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: '-sep "tsv"'
    def prefix = task.ext.prefix != null ? "${task.ext.prefix}" : (meta.patient != null ? "${meta.patient}" : "")
    def flagFiles = maf_files.collect { "-f $it" }.join(' ')
    def output = prefix ? "${prefix}_combined.maf": 'multi_sample.maf'
    """
    pv maf concat \\
        $flagFiles \\
        --output $output \\
        $args


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pv: \$( pv --version )
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: '-sep "tsv"'
    def prefix = task.ext.prefix != null ? "${task.ext.prefix}" : (meta.patient != null ? "${meta.patient}" : "")
    def flagFiles = maf_files.collect { "-f $it" }.join(' ')
    def output = prefix ? "${prefix}_combined.maf": 'multi_sample.maf'
    """
    touch $output

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pv: \$( pv --version )
    END_VERSIONS
    """
}
