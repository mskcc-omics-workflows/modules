process GENERATEMUTFASTA {
    tag "$meta.id"
    label 'process_single'
    container "ghcr.io/mskcc-omics-workflows/neoantigen-utils-base:1.4.0"

    input:
    tuple val(meta),  path(inputMaf)
    path(mutalyzer_cache)

    output:
    tuple val(meta), path("*_out/*.MUT.sequences.fa"),       emit: mut_fasta
    tuple val(meta), path("*_out/*.WT.sequences.fa"),        emit: wt_fasta
    tuple val(meta), path("*_out/*_generate_mut_fasta.log"), emit: mut_fasta_log
    path "versions.yml",                                     emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    # Setup cache

    mkdir -p \$(pwd)/mutalyzer_cache

    tar -xzf ${mutalyzer_cache} -C \$(pwd)/mutalyzer_cache

    cat <<-END_MUTALYZER_CONFIG > \$(pwd)/config.txt
	MUTALYZER_CACHE_DIR = \$(pwd)/mutalyzer_cache/cache
	MUTALYZER_FILE_CACHE_ADD = false
	END_MUTALYZER_CONFIG

    mkdir ${prefix}_out

    MUTALYZER_SETTINGS="\$(pwd)/config.txt" generateMutFasta.py --sample_id ${prefix} \
    --output_dir ${prefix}_out \
    --maf_file ${inputMaf}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        generateMutFasta: \$(echo \$(generateMutFasta.py -v))
        mutalyzer: \$(echo \$(mutalyzer_normalizer -v | tr '\n' ' ' | awk '{print \$3}'))
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
        mkdir ${prefix}_out
        touch ${prefix}_out/${prefix}.MUT.sequences.fa
        touch ${prefix}_out/${prefix}.WT.sequences.fa
        touch ${prefix}_out/${prefix}_generate_mut_fasta.log
        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            generateMutFasta: \$(echo \$(generateMutFasta.py -v))
            mutalyzer: \$(echo \$(mutalyzer_normalizer -v | tr '\n' ' ' | awk '{print \$3}'))
        END_VERSIONS
    """
}
