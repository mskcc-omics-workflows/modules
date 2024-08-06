process IGV_SNAPHSHOT {
    tag "$meta.id"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'ghcr.io/msk-access/igv_snapshot:0.0.1':
        'ghcr.io/msk-access/igv_snapshot:0.0.1' }"

    input:
    tuple val(meta), path(bam), path(bai), path(variant_file)

    output:

    tuple val(meta), path("**igv_output/*"), emit: igv_screenshots
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ""
    def prefix = task.ext.prefix ?: "${meta.id}"
    def bed_name = prefix ? "${prefix}.bed": "variant.bed"
    def out = prefix ? "${prefix}_igv_output": "igv_output"
    def genome = task.ext.genome ? "-g ${task.ext.genome}" : ""
    """
    igv run_screenshot \\
    --input-files $bam \\
    --annotated-variant-file $variant_file \\
    -t $prefix \\
    -o $out \\
    -r $bed_name \\
    $genome

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        igv: \$(igv --version)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ""
    def prefix = task.ext.prefix ?: "${meta.id}"
    def bed_name = prefix ? "${prefix}.bed": "variant.bed"
    def out = prefix ? "${prefix}_igv_output": "igv_output"
    """
    mkdir $out
    touch $out/test.png
    touch $out/test.bat

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        igv: \$(igv --version)
    END_VERSIONS
    """
}
