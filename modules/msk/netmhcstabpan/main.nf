process NETMHCSTABPAN {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/netmhctools:1.0.0':
        'docker.io/mskcc/netmhctools:1.0.0' }"

    input:
    tuple val(meta), path(inputFasta), val(hlaString), val(inputType)


    output:
    tuple val(output_meta), path("*.netmhcstabpan.output"),   emit: netmhcstabpanoutput
    path "versions.yml",                                      emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def hla = hlaString.trim()
    output_meta = meta.clone()
    output_meta.typeMut = inputType == "MUT" ? true : false
    output_meta.fromStab = true

    def NETMHCPAN_VERSION = "4.1"
    def NETMHCSTABPAN_VERSION = "1.0"

    """

    /usr/local/bin/netMHCstabpan-${NETMHCPAN_VERSION}/netMHCstabpan \
    -s -1 \
    -f ${inputFasta} \
    -a ${hla} \
    -l 9,10 \
    -inptype 0 > ${prefix}.${inputType}.netmhcstabpan.output

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        netmhcpan: v${NETMHCPAN_VERSION}
        netmhcstabpan: v${NETMHCPAN_VERSION}
    END_VERSIONS

    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    output_meta = meta.clone()
    output_meta.typeMut = inputType == "MUT" ? true : false
    output_meta.fromStab = true
    """
    touch ${prefix}.MUT.netmhcstabpan.output


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        netmhcpan: v${NETMHCPAN_VERSION}
        netmhcstabpan: v${NETMHCPAN_VERSION}
    END_VERSIONS
    """
}
