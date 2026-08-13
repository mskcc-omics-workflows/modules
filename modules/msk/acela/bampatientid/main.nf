process ACELA_BAMPATIENTID {
    tag "$meta.id"
    label 'process_single'

    // acela-cli authenticates to the internal MSKCC Acela/Voyager API with a session token.
    // Before running a pipeline that uses this module, obtain one (`acela login`)
    secret 'ACELA_TOKEN'
    conda "${moduleDir}/environment.yml"
    // Hosted on MSK's internal JFrog Artifactory rather than ghcr.io -- pulling it (with
    // Docker, Podman, or Singularity/Apptainer) requires the puller to be authenticated
    // to mskcc.jfrog.io first.
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'mskcc.jfrog.io/omicswf-docker-prod-local/mskcc-omics-workflows/acela_cli:0.1.0':
        'mskcc.jfrog.io/omicswf-docker-prod-local/mskcc-omics-workflows/acela_cli:0.1.0' }"

    input:
    tuple val(meta), val(patient_ids)

    output:
    tuple val(meta), path("*.acela_bam.tsv"), emit: tsv
    path "versions.yml",                      emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    if (!(meta.id_type in ['cmo', 'dmp'])) {
        error "ACELA_BAMPATIENTID: meta.id_type must be 'cmo' or 'dmp', got '${meta.id_type}'"
    }
    def subcommand = meta.id_type == 'dmp' ? 'by-dmp-id' : 'by-cmo-id'
    def ids = (patient_ids instanceof List ? patient_ids : [patient_ids]).join(' ')

    """
    acela bam ${subcommand} \\
        ${ids} \\
        --output ${prefix}.acela_bam.tsv \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        acela-cli: \$(echo \$(acela --version) | sed -e "s/acela-cli //g")
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}.acela_bam.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        acela-cli: \$(echo \$(acela --version) | sed -e "s/acela-cli //g")
    END_VERSIONS
    """
}
