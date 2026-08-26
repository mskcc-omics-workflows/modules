process GBCMSRS_DNA {
    tag "$meta.id"
    label 'process_medium'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'ghcr.io/msk-access/gbcms:6.3.0':
        'ghcr.io/msk-access/gbcms:6.3.0' }"
    // The gbcms image sets ENTRYPOINT ["gbcms"], which breaks Nextflow's docker/podman
    // invocation of .command.run unless the entrypoint is cleared here. Singularity
    // ignores the image entrypoint already, so this is scoped to docker/podman only.
    containerOptions { workflow.containerEngine in ['docker', 'podman'] ? "--entrypoint ''" : '' }

    input:
    tuple val(meta), path(variants), val(sample_names), path(bams), path(bais)
    path fasta
    path fasta_fai

    output:
    tuple val(meta), path("gbcms_out/*.{vcf,maf}"), emit: variant_file
    path "versions.yml"                            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        error "GBCMSRS_DNA module does not support Conda. Please use Docker / Singularity instead."
    }
    // gbcms's read filters (--filter-duplicates/-secondary/-supplementary/-qc-failed)
    // default to ON. A pipeline mapping its own boolean params into ext.args must emit
    // the explicit --no-filter-x form when off; omitting the flag silently keeps it on.
    // On Nextflow >=26.04 (strict parser), CLI param overrides arrive as Strings, so
    // `params.x ? 'a' : 'b'` sees "false" as truthy — compare with `.toString() == 'true'`.
    def args = task.ext.args ?: ''
    // Bare `--bam path` labels the sample using the staged file's stem, which is not
    // meaningful for real BAM naming conventions. Pairing each bam with an explicit
    // name keeps the output filename and Tumor_Sample_Barcode/VCF sample column
    // predictable and equal to what the caller intends.
    def bam_args = [sample_names, bams].transpose().collect { name, bam -> "--bam ${name}:${bam}" }.join(' ')
    """
    gbcms dna \\
        --variants ${variants} \\
        ${bam_args} \\
        --fasta ${fasta} \\
        --output-dir gbcms_out \\
        --threads ${task.cpus} \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gbcms: \$(gbcms --version | sed 's/^gbcms //')
    END_VERSIONS
    """

    stub:
    def sample_name = sample_names[0]
    """
    mkdir -p gbcms_out
    touch gbcms_out/${sample_name}.vcf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gbcms: \$(echo "${task.container}" | sed 's/.*://')
    END_VERSIONS
    """
}
