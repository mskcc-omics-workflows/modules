process NEOSV {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/neoantigen-utils-base:1.3.0':
        'docker.io/mskcc/neoantigen-utils-base:1.3.0' }"

    input:
    tuple val(meta),  path(inputBedpe), val(hlaString)
    tuple path(gtf),  path(cdna)

    output:
    tuple val(meta),       path("*.net.in.txt"),               emit: mutOut
    tuple val(meta),       path("*.WT.net.in.txt"),            emit: wtOut
    path "versions.yml",                                       emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def NEOSV_VERSION = 1.1

    """

    echo ${hlaString} | tr ',' '\n' | sed 's/^[ \\t]*//;s/[ \t]*\$//' > hla.txt
    awk 'NF {print substr(\$0,1,5)"*"substr(\$0,6)}' hla.txt > temp_file && mv temp_file hla.txt

    neosv --sv-file test.sv.bedpe \\
    --out ./ \\
    --hla-file hla.txt \\
    --gtf-file ${gtf} \\
    --cdna-file ${cdna} \\
    --pyensembl-cache-dir ./ \\
    --prefix ${prefix}


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        NEOSV: v${NEOSV_VERSION}
    END_VERSIONS

    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def NEOSV_VERSION = 1.1
    """
    touch ${prefix}.WT.net.in.txt
    touch ${prefix}.net.in.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        NEOSV: v${NEOSV_VERSION}
    END_VERSIONS
    """
}
