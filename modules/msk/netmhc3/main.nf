process NETMHC3 {
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
    tuple val(output_meta),       path("*.netmhc.output"),     emit: netmhcoutput
    tuple val(output_meta),       path("*.hla_*.txt"),         emit: netmhc_hla_files
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
    output_meta.fromPan = false
    def NETMHC_VERSION = "3.4"
    def tmpDir = "netmhc-tmp"
    def tmpDirFullPath = "\$PWD/${tmpDir}/"  // must set full path to tmp directories for netMHC and netMHCpan to work; for some reason doesn't work with /scratch, so putting them in the process workspace

    """
    export TMPDIR=${tmpDirFullPath}
    mkdir -p ${tmpDir}
    chmod 777 ${tmpDir}

    HLA_ACCEPTED=\$(trim_hla.py --hla ${hla})

    cat ${inputSVFasta} >> ${inputFasta}

    /usr/local/bin/netMHC-3.4/netMHC \
    -a \$HLA_ACCEPTED \
    -s \
    -l 9 \
    --xls=${prefix}.${inputType}.xls \
    ${inputFasta} > ${prefix}.${inputType}.netmhc.output

    mv hla_accepted.txt ${prefix}.hla_accepted.txt
    mv hla_rejected.txt ${prefix}.hla_rejected.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        netmhc: v${NETMHC_VERSION}
    END_VERSIONS

    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def NETMHC_VERSION = "3.4"
    output_meta = meta.clone()
    output_meta.typeMut = inputType == "MUT" ? true : false
    output_meta.fromStab = false
    output_meta.typePan = false
    """
    touch ${prefix}.MUT.netmhc.output
    touch ${prefix}.MUT.xls
    touch ${prefix}.hla_accepted.txt
    touch ${prefix}.hla_rejected.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        netmhc: v${NETMHC_VERSION}
    END_VERSIONS
    """
}
