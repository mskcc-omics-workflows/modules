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
    path "versions.yml"                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def phylo_run_dir = "${workflow.workDir}/.scratch/${task.process}_${prefix}"

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

    cd ${task.workDir}
    cp -r ${phylo_run_dir}/chains .

    rm -rf ${phylo_run_dir}

    cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    phylowgs: \$PHYLOWGS_TAG
	END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir chains
    touch chains/trees.zip

    cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    phylowgs: \$PHYLOWGS_TAG
	END_VERSIONS
    """
}
