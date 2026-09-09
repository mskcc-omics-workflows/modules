process MUTALYZER_RETRIEVER {
    tag "$meta.id"
    label 'process_medium'
    container "ghcr.io/mskcc-omics-workflows/neoantigen-utils-base:1.6.0"

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


        # Read first 3 bytes and route by magic: bgzip=1f8b08,gzip=1f8b08, bzip2=425a68.
        # Plain-text FASTA/FASTQ commonly starts with '>' (3e) or '@' (40).
        MAGIC=\$(head -c 3 "${fasta}" | od -An -tx1 | tr -d ' \n')

        case "\$MAGIC" in
            1f8b08)
                if ! bgzip --reindex ${fasta} > /dev/null 2>&1; then
                    mv ${fasta} ${fasta.baseName}.tmp.gzip
                    gunzip -c ${fasta.baseName}.tmp.gzip | bgzip -c > ${fasta}
                fi
                ;;
            425a68)
                mv ${fasta} ${fasta.baseName}.tmp.bzip2
                bunzip2 -c "${fasta.baseName}.tmp.bzip2" | bgzip -c > ${fasta}
                ;;
            3e*|40*)
                mv ${fasta} ${fasta.baseName}.tmp
                bgzip -c "${fasta.baseName}.tmp" > "${fasta}"
                ;;
            *)
                echo "ERROR: Unsupported input format for ${fasta}." >&2
                echo "       Expected: bgzip/gzip, bzip2, or plain-text FASTA/FASTQ." >&2
                exit 1
                ;;
        esac

        bgzip --reindex ${fasta}

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
