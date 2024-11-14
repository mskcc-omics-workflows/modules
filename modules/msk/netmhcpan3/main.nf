process NETMHCPAN3 {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/netmhctools:1.1.0':
        'docker.io/mskcc/netmhctools:1.1.0' }"

    input:
    tuple val(meta),  path(inputFasta), val(hlaString), val(inputType)

    output:
    tuple val(output_meta),       path("*.xls"),               emit: xls
    tuple val(output_meta),       path("*.netmhcpan.output"),  emit: netmhcpanoutput
    tuple val(output_meta),       path("hla_*.txt"),           emit: netmhc_hla_files
    path "versions.yml",                                       emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def hla = hlaString.trim()
    output_meta = meta.clone()
    output_meta.typeMut = inputType == "MUT" ? true : false
    output_meta.fromStab = false
    def NETMHCPAN_VERSION = "3.4"

    """
    HLA_ACCEPTED=\$(trim_hla.py --hla ${hla})

    /usr/local/bin/netMHC-3.4/netMHC \
    -a \$HLA_ACCEPTED \
    -s \
    -l 9 \
    --xls=${prefix}.${inputType}.xls \
    ${inputFasta} > ${prefix}.${inputType}.netmhcpan.output

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        netmhcpan: v${NETMHCPAN_VERSION}
    END_VERSIONS

    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def NETMHCPAN_VERSION = "3.4"
    output_meta = meta.clone()
    output_meta.typeMut = inputType == "MUT" ? true : false
    output_meta.fromStab = false
    """
    touch ${prefix}.MUT.netmhcpan.output
    touch ${prefix}.MUT.xls

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        netmhcpan: v${NETMHCPAN_VERSION}
    END_VERSIONS
    """
}
