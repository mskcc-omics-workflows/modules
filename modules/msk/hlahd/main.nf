process HLAHD {
    tag "$meta.id"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://ghcr.io/mskcc-omics-workflows/hlahd:1.7.1':
        'ghcr.io/mskcc-omics-workflows/hlahd:1.7.1' }"

    input:
    tuple val(meta), path(fastq_1), path(fastq_2)

    output:
    tuple val(meta), path("${prefix}/${prefix}_final.result.txt"), emit: result
    tuple val(meta), path("${prefix}/result/*_result.txt"),        emit: result_per_locus
    path "versions.yml",                                           emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args        = task.ext.args  ?: ''
    def min_read    = task.ext.args2 ?: '100'
    prefix          = task.ext.prefix ?: "${meta.id}"
    def install_dir = '/opt/hlahd/current'
    """
    if [[ \$(ulimit -n) -lt 1024 ]]; then ulimit -n 1024; fi

    ln -sf /usr/bin/python3 ./python
    export PATH=\$PWD:\$PATH

    mkdir -p ${prefix}

    bash ${install_dir}/bin/hlahd.sh \\
        -t ${task.cpus} \\
        -m ${min_read} \\
        -f ${install_dir}/freq_data \\
        ${args} \\
        ${fastq_1} \\
        ${fastq_2} \\
        ${install_dir}/HLA_gene.split.txt \\
        ${install_dir}/dictionary \\
        ${prefix} \\
        .

    HLAHD_VERSION=\$(bash ${install_dir}/bin/hlahd.sh 2>&1 | grep -oP 'HLA-HD version \\K[0-9.]+' | head -1)

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        hlahd: \${HLAHD_VERSION}
    END_VERSIONS
    """

    stub:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir -p ${prefix}/result
    touch ${prefix}/${prefix}_final.result.txt
    touch ${prefix}/result/${prefix}_A_result.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        hlahd: 1.7.1
    END_VERSIONS
    """
}
