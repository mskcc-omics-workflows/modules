process NEOANTIGENINPUT {
    tag "$meta.id"
    label 'process_single'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/neoantigeninputs:1.0.4':
        'docker.io/mskcc/neoantigeninputs:1.0.4' }"

    input:
    tuple val(meta),  path(inputMaf),      path(hlaFile)
    tuple val(meta2), path(phyloWGSsumm),  path(phyloWGSmut),   path(phyloWGSfolder)
    tuple val(meta3), path(mutNetMHCpan),  path(wtNetMHCpan)

    output:
    tuple val(meta), path("*_.json"),                                                  emit: json
    tuple val(meta), path("*.MUT.tsv"), path("*.WT.tsv"),                              emit: netMHCpanreformatted
    path "versions.yml",                                                               emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def id = task.ext.prefix ?: "${meta.id}"
    def patientid = task.ext.cohort ?: "${meta.id}_patient"
    def cohort = task.ext.cohort ?: "${meta.id}_cohort"
    
    """
        tree_folder_name=\$(basename -s .zip "${phyloWGSfolder}")
        mkdir \$tree_folder_name
        unzip ${phyloWGSfolder} -d \$tree_folder_name

        gzip -d -c ${phyloWGSsumm} > ${id}.summ.json
        gzip -d -c ${phyloWGSmut} > ${id}.mut.json

        

        python3 /usr/bin/eval_phyloWGS.py --maf_file ${inputMaf} \
        --summary_file ${id}.summ.json \
        --mutation_file ${id}.mut.json \
        --tree_directory \$tree_folder_name \
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
    
        touch ${patientid}_${id}_.json
        touch ${patientid}.MUT.tsv
        touch ${patientid}.WT.tsv
        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            neoantigeninput: \$(echo \$(python3 /usr/bin/eval_phyloWGS.py -v))
        END_VERSIONS
    """
}
