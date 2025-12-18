process MUTALYZER_NORMALIZER {
    tag "$meta.id"
    label 'process_single'
    container "ghcr.io/mskcc-omics-workflows/neoantigen-utils-base:1.4.0"

    input:
    tuple val(meta), val(hgvs_description)
    path(mutalyzer_cache)


    output:
    tuple val(meta), path("*.json"),         emit: normalized_model
    path "versions.yml",                     emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    # Setup cache

    mkdir -p ${task.workDir}/mutalyzer_cache

    tar -xzf ${mutalyzer_cache} -C ${task.workDir}/mutalyzer_cache

    cat <<-END_MUTALYZER_CONFIG > ${task.workDir}/config.txt
	MUTALYZER_CACHE_DIR = "${task.workDir}/mutalyzer_cache/cache"
	MUTALYZER_FILE_CACHE_ADD = false
	END_MUTALYZER_CONFIG

    MUTALYZER_SETTINGS="${task.workDir}/config.txt" mutalyzer_normalizer ${hgvs_description} > ${prefix}_${hgvs_description}.json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mutalyzer: \$(echo \$(mutalyzer_normalizer -v | tr '\n' ' ' | awk '{print \$3}'))
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}_${hgvs_description}.json
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mutalyzer: \$(echo \$(mutalyzer_normalizer -v | tr '\n' ' ' | awk '{print \$3}'))
    END_VERSIONS
    """
}
