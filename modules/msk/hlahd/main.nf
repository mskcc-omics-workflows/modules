process HLAHD {
    tag "$meta.id"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc.jfrog.io/omicswf-docker-prod-local/mskcc-omics-workflows/hlahd:1.7.1':
        'mskcc.jfrog.io/omicswf-docker-prod-local/mskcc-omics-workflows/hlahd:1.7.1' }"

    input:
    tuple val(meta), path(fastq_1), path(fastq_2)

    output:
    tuple val(meta), path("${prefix}/result/${prefix}_final.result.txt"), emit: result
    tuple val(meta), path("${prefix}/result/${prefix}_*.est.txt"),       emit: result_per_locus
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
    export PATH=\$PWD:${install_dir}/bin:\$PATH

    echo "===== DIAG: /opt/hlahd ====="; ls -la /opt/hlahd/ 2>&1 || true
    echo "===== DIAG: /opt/hlahd/current (resolves to) ====="; readlink -f /opt/hlahd/current 2>&1 || true
    echo "===== DIAG: /opt/hlahd/current/bin ====="; ls -la /opt/hlahd/current/bin/ 2>&1 || true
    echo "===== DIAG: /opt/hlahd/current/dictionary ====="; ls -la /opt/hlahd/current/dictionary/ 2>&1 | head -40 || true
    echo "===== DIAG: /opt/hlahd/current/freq_data ====="; ls -la /opt/hlahd/current/freq_data/ 2>&1 | head -10 || true
    echo "===== DIAG: top-level /opt/hlahd/current ====="; ls -la /opt/hlahd/current/ 2>&1 || true
    echo "===== DIAG: which pm_extract ====="; which pm_extract 2>&1 || true
    echo "===== DIAG: PATH ====="; echo "\$PATH"

    mkdir -p ${prefix}

    bash ${install_dir}/bin/hlahd.sh \\
        -t ${task.cpus} \\
        -m ${min_read} \\
        -f ${install_dir}/freq_data \\
        ${args} \\
        ${fastq_1} \\
        ${fastq_2} \\
        ${install_dir}/HLA_gene.split.3.50.0.txt \\
        ${install_dir}/dictionary \\
        ${prefix} \\
        .

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        hlahd: \$(bash ${install_dir}/bin/hlahd.sh 2>&1 | grep -oP 'HLA-HD version \\K[0-9.]+' | head -1)
    END_VERSIONS
    """

    stub:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir -p ${prefix}/result
    touch ${prefix}/result/${prefix}_final.result.txt
    touch ${prefix}/result/${prefix}_A.est.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        hlahd: \$(bash /opt/hlahd/current/bin/hlahd.sh 2>&1 | grep -oP 'HLA-HD version \\K[0-9.]+' | head -1)
    END_VERSIONS
    """
}
