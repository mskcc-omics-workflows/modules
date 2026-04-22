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
        # Determine compression type by magic bytes before attempting recompression
        MAGIC=\$(xxd -l 2 -p ${fasta})
        if [ "\$MAGIC" = "1f8b" ]; then
            # Standard gzip — re-compress with bgzip
            mv ${fasta} ${fasta.baseName}.tmp.gzip
            gunzip -c ${fasta.baseName}.tmp.gzip | bgzip -c > ${fasta}
            bgzip --reindex ${fasta}
            rm ${fasta.baseName}.tmp.gzip
        elif [ "\$MAGIC" = "425a" ]; then
            echo "ERROR: ${fasta} is bzip2-compressed. Please provide a gzip or bgzip-compressed FASTA." >&2
            exit 1
        else
            echo "ERROR: ${fasta} does not appear to be gzip-compressed or bgzip-indexed." >&2
            echo "       Please provide a bgzip-compressed FASTA (e.g. bgzip genome.fa)." >&2
            exit 1
        fi
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
