process CUSTOM_FINGERPRINTCOMBINE {
    tag '$meta.id'
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://community.wave.seqera.io/library/r-argparse_r-data.table_r-dplyr_r-plyr_r-tidyverse:8c0daffb3624cb66':
        'community.wave.seqera.io/library/r-argparse_r-data.table_r-dplyr_r-plyr_r-tidyverse:8c0daffb3624cb66' }"
        //'	oras://community.wave.seqera.io/library/r-argparse_r-data.table_r-dplyr_r-plyr_r-tidyverse:d96a65055f79744c':


    input:
    tuple val(meta), path(fp_tsv), val(sample), val(genome_build)
    path(liftover_loci_mapping)

    output:
    tuple val(meta), path("*DPfilter_ALL_FP.txt")                         , emit: combined_fp_tsv
    tuple val("${task.process}"), val('complete_FP_table.R'), val('0.1.0'), emit: versions_fingerprintcombine, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    declare -a fp_tsv_list
    declare -a sample_list
    declare -a genome_build_list
    fp_tsv_list=(${fp_tsv.join(' ')})
    sample_list=(${sample.join(' ')})
    genome_build_list=(${genome_build.join(' ')})
    echo -e "sample_id\tgenome_build\tfp_tsv" > input.tsv
    for i in \$(seq 0 1 \$((\${#fp_tsv_list[@]}-1)) ) ; do
        fp_tsv=\${fp_tsv_list[i]}
        sample=\${sample_list[i]}
        genome=\${genome_build_list[i]}
        echo -e "\$sample\t\$genome\t\$fp_tsv"
    done >> input.tsv

    complete_FP_table.R \\
        -i input.tsv \\
        -l $liftover_loci_mapping \\
        $args
    """

    stub:
    def args = task.ext.args ?: ''

    """
    echo $args

    touch XDPfilter_ALL_FP.txt
    """
}
