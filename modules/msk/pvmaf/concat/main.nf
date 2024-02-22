process PVMAF_CONCAT {
    tag "$meta.id"
    label 'process_single'

    // TODO nf-core: List required Conda package(s).
    //               Software MUST be pinned to channel (i.e. "bioconda"), version (i.e. "1.10").
    //               For Conda, the build (i.e. "h9402c20_2") must be EXCLUDED to support installation on different operating systems.
    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'ghcr.io/msk-access/postprocessing_variant_calls:0.2.7':
        'ghcr.io/msk-access/postprocessing_variant_calls:0.2.7' }"

    input:
    tuple val(meta), path(files)
    path(header)

    output:
    tuple val(meta), path("*.maf"), emit: maf
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: '-sep "tsv"'
    def prefix = task.ext.prefix != null ? "${task.ext.prefix}" : (meta.patient != null ? "${meta.patient}" : "")
    def flagFiles = files.collect { "-f $it" }.join(' ')
    def output = prefix ? "${prefix}_combined.maf": 'multi_sample.maf'
    """
    pv maf concat \\
        $flagFiles \\
        $header \\
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
    def flagFiles = files.collect { "-f $it" }.join(' ')
    def output = prefix ? "${prefix}_combined.maf": 'multi_sample.maf'
    """
    touch $output

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pv: \$( pv --version )
    END_VERSIONS
    """
}
