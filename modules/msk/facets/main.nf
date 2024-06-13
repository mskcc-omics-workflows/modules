process FACETS {
    tag "$meta.id"
    label 'process_medium'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/facets-suite:2.0.9':
        'docker.io/mskcc/facets-suite:2.0.9' }"


    input:

    tuple val(meta), path(snp_pileup), val(legacy_output_mode)  //  [ meta, ${prefix}.snp_pileup.gz, false]


    output:
    tuple val(meta), path("*_purity.seg")              , emit: purity_seg
    tuple val(meta), path("*_purity.?d*")              , emit: purity_r_data
    tuple val(meta), path("*_purity*png")              , emit: purity_png
    tuple val(meta), path("*_purity.out")              , emit: purity_out, optional: true
    tuple val(meta), path("*_purity.cncf.txt")         , emit: purity_cncf_txt, optional: true
    tuple val(meta), path("*_hisens.seg")              , emit: hisens_seg
    tuple val(meta), path("*_hisens.?d*")              , emit: hisens_r_data
    tuple val(meta), path("*_hisens*png")              , emit: hisens_png
    tuple val(meta), path("*_hisens.out")              , emit: hisens_out, optional: true
    tuple val(meta), path("*_hisens.cncf.txt")         , emit: hisens_cncf_txt, optional: true
    tuple val(meta), path("*.qc.txt")                  , emit: qc_txt
    tuple val(meta), path("*.gene_level.txt")          , emit: gene_level_txt
    tuple val(meta), path("*.arm_level.txt")           , emit: arm_level_txt
    tuple val(meta), path("${meta.id}.txt")            , emit: output_txt, optional: true
    path "versions.yml"                                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def legacy_output_arg = legacy_output_mode ? '--legacy-output TRUE' : ''

    """
    /usr/bin/facets-suite/run-facets-wrapper.R \
        ${args} \
        ${legacy_output_arg} \
        --sample-id ${prefix} \
        --counts-file ${snp_pileup}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        facets_suite: \$(Rscript -e "packageVersion('facetsSuite')" | grep -oP "\\d+.\\d+.\\d+")
        facets: \$(Rscript -e "packageVersion('facets')" | grep -oP "\\d+.\\d+.\\d+")
        r: \$(R --version | grep -oP '(?<=R version ).*(?=\\()')
        pctGCdata: \$(Rscript -e "packageVersion('pctGCdata')" | grep -oP "\\d+.\\d+.\\d+")
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_purity.seg
    touch ${prefix}_purity.CNCF.png
    touch ${prefix}_purity.png
    touch ${prefix}_purity.cncf.txt
    touch ${prefix}_purity.Rdata
    touch ${prefix}_purity.rds
    touch ${prefix}_purity.out
    touch ${prefix}_hisens.seg
    touch ${prefix}_hisens.CNCF.png
    touch ${prefix}_hisens.png
    touch ${prefix}_hisens.cncf.txt
    touch ${prefix}_hisens.Rdata
    touch ${prefix}_hisens.rds
    touch ${prefix}_hisens.out
    touch ${prefix}.qc.txt
    touch ${prefix}.gene_level.txt
    touch ${prefix}.arm_level.txt
    touch ${prefix}.txt



    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        facets_suite: \$(Rscript -e "packageVersion('facetsSuite')" | grep -oP "\\d+.\\d+.\\d+")
        facets: \$(Rscript -e "packageVersion('facets')" | grep -oP "\\d+.\\d+.\\d+")
        r: \$(R --version | grep -oP '(?<=R version ).*(?=\\()')
        pctGCdata: \$(Rscript -e "packageVersion('pctGCdata')" | grep -oP "\\d+.\\d+.\\d+")
    END_VERSIONS
    """
}

