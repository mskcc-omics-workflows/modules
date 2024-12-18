process NETMHCSTABPAN {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/netmhctools:1.1.0':
        'docker.io/mskcc/netmhctools:1.1.0' }"

    input:
    tuple val(meta),  path(inputFasta), path(inputSVFasta, arity: '0..*'), val(hlaString), val(inputType)


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
    output_meta.fromPan = true

    def NETMHCPAN_VERSION = "4.1"
    def NETMHCSTABPAN_VERSION = "1.0"
    
    def tmpDir = "netmhc-tmp"
    def tmpDirFullPath = "\$PWD/${tmpDir}/"  // must set full path to tmp directories for netMHC and netMHCpan to work; for some reason doesn't work with /scratch, so putting them in the process workspace

    """
    export TMPDIR=${tmpDirFullPath}
    mkdir -p ${tmpDir}
    chmod 777 ${tmpDir}
    
    cat ${inputSVFasta} >> ${inputFasta}

    /usr/local/bin/netMHCstabpan-${NETMHCSTABPAN_VERSION}/netMHCstabpan \
    -s -1 \
    -f ${inputFasta} \
    -a ${hla} \
    -l 9,10 \
    -inptype 0 > ${prefix}.${inputType}.netmhcstabpan.output

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        netmhcpan: v${NETMHCPAN_VERSION}
        netmhcstabpan: v${NETMHCSTABPAN_VERSION}
    END_VERSIONS

    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    output_meta = meta.clone()
    output_meta.typeMut = inputType == "MUT" ? true : false
    output_meta.fromStab = true
    output_meta.typePan = true
    def NETMHCPAN_VERSION = "4.1"
    def NETMHCSTABPAN_VERSION = "1.0"

    """
    touch ${prefix}.MUT.netmhcstabpan.output


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        netmhcpan: v${NETMHCPAN_VERSION}
        netmhcstabpan: v${NETMHCSTABPAN_VERSION}
    END_VERSIONS
    """
}
