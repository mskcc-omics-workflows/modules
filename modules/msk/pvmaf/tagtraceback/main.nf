process PVMAF_TAGTRACEBACK {
    tag "$meta.id"
    label 'process_single'
    // TODO nf-core: List required Conda package(s).
    //               Software MUST be pinned to channel (i.e. "bioconda"), version (i.e. "1.10").
    //               For Conda, the build (i.e. "h9402c20_2") must be EXCLUDED to support installation on different operating systems.
    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'ghcr.io/msk-access/postprocessing_variant_calls:type_traceback_0.0.7':
        'ghcr.io/msk-access/postprocessing_variant_calls:type_traceback_0.0.7' }"

    input:
    tuple val(meta), path(maf) // [ id:'sample1', patient:'patient1' ], *.maf
    path(sample_sheets) // [samplesheet_1, ..., samplesheet_n]

    output:
    tuple val(meta), path("*.maf"), emit: maf
    path "versions.yml"           , emit: versions
    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix != null ? "${task.ext.prefix}" : (meta.patient != null ? "${meta.patient}" : "")
    def sampleFiles = sample_sheets ? sample_sheets.collect { file -> "-sheet $file" }.join(' ') : ''
    def output = prefix ? "${prefix}_traceback.maf": "multi_sample_traceback.maf"

    """
    pv maf tag traceback \\
    -m $maf \\
    $sampleFiles \\
    --output $output \\
    $args


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pv: \$( pv --version  )
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix != null ? "${task.ext.prefix}" : (meta.patient != null ? "${meta.patient}" : "")
    def output = prefix ? "${prefix}_traceback.maf": "multi_sample_traceback.maf"
    """
    touch $output
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pv: \$( pv --version  )
    END_VERSIONS
    """
}
