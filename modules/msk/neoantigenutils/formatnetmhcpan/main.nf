process NEOANTIGENUTILS_FORMATNETMHCPAN {
    tag "$meta.id"
    label 'process_single'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/neoantigen-utils-base:1.3.0':
        'docker.io/mskcc/neoantigen-utils-base:1.3.0' }"

    input:
    tuple val(meta),  path(netmhcPanOutput)

    output:
    tuple val(meta), path("*.tsv"),              emit: netMHCpanreformatted
    path "versions.yml",                         emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def netmhcOutputType = meta.typeMut ? "--type_MUT": ""
    def netmhcOutputFrom = meta.fromStab ? "--from_STAB": ""
    def netmhcOutputPan  = meta.fromPan ? "": "--from_NETMHC3"

    """
        format_netmhcpan_output.py \
            --netMHCpan_output ${netmhcPanOutput} \
            --id ${prefix} \
            ${netmhcOutputPan} \
            ${netmhcOutputType} \
            ${netmhcOutputFrom}

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            formatNetmhcpanOutput: \$(echo \$(format_netmhcpan_output.py -v))
        END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def netmhcOutputType = meta.typeMut ? "MUT": "WT"
    def netmhcOutputFrom = meta.fromStab ? "STAB": "PAN"
    """
        touch ${prefix}.${netmhcOutputType}.${netmhcOutputFrom}.tsv
        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            formatNetmhcpanOutput: \$(echo \$(format_netmhcpan_output.py -v))
        END_VERSIONS
    """
}
