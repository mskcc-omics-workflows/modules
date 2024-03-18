process NEOANTIGENINPUT {
    tag "$meta.id"
    label 'process_single'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/neoantigeninputs:1.0.1':
        'docker.io/mskcc/neoantigeninputs:1.0.1' }"

    input:
    tuple val(meta), path(inputMaf)
    tuple path(phyloWGSsumm), path(phyloWGSmut), path(phyloWGSfolder)
    tuple val(meta2), path(mutNetMHCpan), path(wtNetMHCpan)
    path(hlaFile)

    output:
    tuple val(meta), path("*_.json"), emit: json
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def id = task.ext.prefix ?: "${meta.id}"
    def patientid = task.ext.cohort ?: "${meta.id}_patient"
    def cohort = task.ext.cohort ?: "${meta.id}_cohort"
    
    """
        ls ${phyloWGSfolder}
        python3 /usr/bin/eval_phyloWGS.py --maf_file ${inputMaf} \
        --summary_file ${phyloWGSsumm} \
        --mutation_file ${phyloWGSmut} \
        --tree_directory ${phyloWGSfolder} \
        --id ${id} --patient_id ${patientid} \
        --cohort ${cohort} --HLA_genes ${hlaFile} \
        --netMHCpan_MUT_input ${mutNetMHCpan} \
        --netMHCpan_WT_input ${wtNetMHCpan}
        ${args}

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            neoantigeninput: \$(echo \$(python3 /usr/bin/eval_phyloWGS.py -v))
        END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def id = task.ext.prefix ?: "${meta.id}"
    def patientid =task.ext.cohort ?: "${meta.id}_patient"
    def cohort =task.ext.cohort ?: "${meta.id}_cohort"
    """
    
        ${patientid}_${id}_.json
        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            neoantigeninput: \$(echo \$(python3 /usr/bin/eval_phyloWGS.py -v))
        END_VERSIONS
    """
}
