process MUTALYZER_RETRIEVER {
    tag "$meta.id"
    label 'process_medium'
    container "ghcr.io/mskcc-omics-workflows/neoantigen-utils-base:1.4.0"

    input:
    tuple val(meta), path(fasta), path(gff3)

    output:
    path("*.tar.gz"),                           emit: mutalyzer_cache
    path "versions.yml",                        emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    if ! bgzip --reindex ${fasta} > /dev/null 2>&1
    then
        # Re-compress fasta with bgzip

        mv ${fasta} ${fasta.baseName}.tmp.gzip
        gunzip -c ${fasta.baseName}.tmp.gzip | bgzip -c > ${fasta}
        bgzip --reindex ${fasta}
    fi

    # Build cache

    mutalyzer_retriever \
        --split --output cache \
        from_file \
        --multi \
        --paths \
        ${gff3} \
        ${fasta}

    # Compress cache

    sleep 15 # ensure all file handles are closed

    tar -zcf ${prefix}.tar.gz cache/

    cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    mutalyzer: \$(echo \$(mutalyzer_normalizer -v | tr '\n' ' ' | awk '{print \$3}'))
	END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}.tar.gz
    cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    mutalyzer: \$(echo \$(mutalyzer_normalizer -v | tr '\n' ' ' | awk '{print \$3}'))
	END_VERSIONS
    """
}
