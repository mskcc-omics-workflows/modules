process REDISCOVERTE {
    tag "Sample(s) - ${[quant].flatten().size()}"
    label 'process_medium'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/rediscoverte:1.0.0':
        'docker.io/mskcc/rediscoverte:1.0.0' }"

    input:

    path quant
    path rmsk_annotation,                 stageAs: 'rollup_annotation/rmsk_annotation.RDS'
    path repName_repFamily_repClass_map,  stageAs: 'rollup_annotation/repName_repFamily_repClass_map.tsv'
    path genecode_annotation,             stageAs: 'rollup_annotation/GENCODE.V26.Basic_Gene_Annotation_md5.RDS'

    output:
    path "REdiscoverTE_rollup"            , emit: rollup
    path "versions.yml"                   , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def threads = task.cpus * 2

    """
    echo -e "sample\tquant_sf_path" > REdiscoverTE.tsv
    ls -1 *.quant.sf | awk -F. '{print \$1\"\\t\"\$0}' >> REdiscoverTE.tsv

    rollup.R \\
        --metadata=REdiscoverTE.tsv \\
        --datadir=rollup_annotation \\
        --nozero --threads=${threads} \\
        ${args} \\
        --outdir=REdiscoverTE_rollup

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        rediscoverte: 1.0.0
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''

    """
    mkdir REdiscoverTE_rollup
    touch REdiscoverTE_rollup/abc.RDS

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        rediscoverte: 1.0.0
    END_VERSIONS
    """
}
