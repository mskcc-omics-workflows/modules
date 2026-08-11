process PHYLOWGS_MULTIEVOLVE {
    tag "$meta.id"
    label 'process_high'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://ghcr.io/mskcc-omics-workflows/phylowgs:v1.5-msk':
        'ghcr.io/mskcc-omics-workflows/phylowgs:v1.5-msk' }"

    input:
    tuple val(meta), path(cnv_data), path(ssm_data)

    output:
    tuple val(meta), path("trees.zip")          , emit: trees
    path "versions.yml"                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def phylo_checkpoint = "${workflow.workDir}/.scratch/${task.process}_${prefix}"
    def chains = "${phylo_checkpoint}/chains"

    """
    mkdir -p ${chains}
    ln -sfn ${chains} chains
    cp -f ${ssm_data} ${phylo_checkpoint}
    cp -f ${cnv_data} ${phylo_checkpoint}

    python2 \\
        /usr/bin/phylowgs/multievolve.py  \\
        ${args} \\
        --ssms ${phylo_checkpoint}/${ssm_data.name} \\
        --cnvs ${phylo_checkpoint}/${cnv_data.name}

    cp chains/trees.zip trees.zip
    rm -rf ${phylo_checkpoint}

    cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    phylowgs: \$PHYLOWGS_TAG
	END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch trees.zip

    cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    phylowgs: \$PHYLOWGS_TAG
	END_VERSIONS
    """
}
