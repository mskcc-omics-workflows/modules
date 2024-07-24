process NEOANTIGENUTILS_GENERATEMUTFASTA {
    tag "$meta.id"
    label 'process_single'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/neoantigen-utils-base:1.0.0':
        'docker.io/mskcc/neoantigen-utils-base:1.0.0' }"

    input:
    tuple val(meta),  path(inputMaf)
    tuple path(cds),  path(cdna)

    output:
    tuple val(meta), path("*_out/*.MUT_sequences.fa"),     emit: mut_fasta
    tuple val(meta), path("*_out/*.WT_sequences.fa"),      emit: wt_fasta
    path "versions.yml",                                   emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    mkdir ${prefix}_out

    generateMutFasta.py --sample_id ${prefix} \
    --output_dir ${prefix}_out \
    --maf_file ${inputMaf} \
    --CDS_file ${cds} \
    --CDNA_file ${cdna}


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        generateMutFasta: \$(echo \$(generateMutFasta.py -v))
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
        mkdir ${prefix}_out
        touch ${prefix}_out/${prefix}.MUT_sequences.fa
        touch ${prefix}_out/${prefix}.WT_sequences.fa
        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            generateMutFasta: \$(echo \$(generateMutFasta.py -v))
        END_VERSIONS
    """
}
