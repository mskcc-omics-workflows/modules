process NETMHCPAN4 {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/netmhctools:1.1.0':
        'docker.io/mskcc/netmhctools:1.1.0' }"

    input:
    tuple val(meta),  path(inputFasta), path(inputSVFasta, arity: '0..*'), val(hlaString), val(inputType)

    output:
    tuple val(output_meta),       path("*.xls"),               emit: xls
    tuple val(output_meta),       path("*.netmhcpan.output"),  emit: netmhcpanoutput
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
    output_meta.fromPan = true
    def NETMHCPAN_VERSION = "4.1"
    def tmpDir = "netmhc-tmp"
    def tmpDirFullPath = "\$PWD/${tmpDir}/"  // must set full path to tmp directories for netMHC and netMHCpan to work; for some reason doesn't work with /scratch, so putting them in the process workspace

    """
    export TMPDIR=${tmpDirFullPath}
    mkdir -p ${tmpDir}
    chmod 777 ${tmpDir}


    cat ${inputSVFasta} >> ${inputFasta}
    /usr/local/bin/netMHCpan-${NETMHCPAN_VERSION}/netMHCpan \
    -s 0 \
    -BA 1 \
    -f ${inputFasta} \
    -a ${hla} \
    -l 9,10 \
    -inptype 0 \
    -xls \
    ${args} \
    -xlsfile \
    ${prefix}.${inputType}.xls > ${prefix}.${inputType}.netmhcpan.output


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        netmhcpan: v${NETMHCPAN_VERSION}
    END_VERSIONS

    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def NETMHCPAN_VERSION = "4.1"
    output_meta = meta.clone()
    output_meta.typeMut = inputType == "MUT" ? true : false
    output_meta.fromStab = false
    output_meta.typePan = true
    """
    touch ${prefix}.MUT.xls
    touch ${prefix}.MUT.netmhcpan.output

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        netmhcpan: v${NETMHCPAN_VERSION}
    END_VERSIONS
    """
}
