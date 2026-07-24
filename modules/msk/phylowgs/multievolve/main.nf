process PHYLOWGS_MULTIEVOLVE {
    tag "$meta.id"
    label 'process_high'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://ghcr.io/mskcc-omics-workflows/phylowgs:v1.5-msk':
        'ghcr.io/mskcc-omics-workflows/phylowgs:v1.5-msk' }"

    input:
    tuple val(meta), path(cnv_data), path(ssm_data)

    output:
    tuple val(meta), path("chains/trees.zip")   , emit: trees
    tuple val(meta), path("*.summ.json.gz")     , emit: summ
    tuple val(meta), path("*.muts.json.gz")     , emit: muts
    tuple val(meta), path("*.mutass.zip")       , emit: mutass
    path "versions.yml"                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def unique_task_id = "${task.process}_index_${task.index}"
    def phylo_run_dir = "${workflow.workDir}/.scratch/${unique_task_id}"

    """
    mkdir -p ${phylo_run_dir}
    cp -u ${ssm_data} ${phylo_run_dir}/
    cp -u ${cnv_data} ${phylo_run_dir}/
    cd ${phylo_run_dir}

    python2 \\
        /usr/bin/phylowgs/multievolve.py  \\
        ${args} \\
        --ssms ${ssm_data.name} \\
        --cnvs ${cnv_data.name}

    python2 \\
        /usr/bin/phylowgs/write_results.py \\
        ${args2} \\
        --include-ssm-names \\
        ${prefix} \\
        chains/trees.zip \\
        ${prefix}.summ.json.gz \\
        ${prefix}.muts.json.gz \\
        ${prefix}.mutass.zip

    cp -r chains ${task.workDir}/
    cp ${prefix}.summ.json.gz ${task.workDir}/
    cp ${prefix}.muts.json.gz ${task.workDir}/
    cp ${prefix}.mutass.zip ${task.workDir}/

    rm -rf ${phylo_run_dir}

    cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    phylowgs: \$PHYLOWGS_TAG
	END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir chains
    touch chains/trees.zip
    touch ${prefix}.summ.json.gz
    touch ${prefix}.muts.json.gz
    touch ${prefix}.mutass.zip

    cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    phylowgs: \$PHYLOWGS_TAG
	END_VERSIONS
    """
}
