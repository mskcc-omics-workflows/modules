process NEOANTIGENUTILS_NEOANTIGENINPUT {
    tag "$meta.id"
    label 'process_single'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://mskcc/neoantigen-utils-base:1.1.0':
        'docker.io/mskcc/neoantigen-utils-base:1.1.0' }"

    input:
    tuple val(meta),  path(inputMaf),      path(hlaFile)
    tuple val(meta2), path(phyloWGSsumm),  path(phyloWGSmut),   path(phyloWGSfolder)
    tuple val(meta3), path(mutNetMHCpan),  path(wtNetMHCpan)

    output:
    tuple val(meta), path("*_.json"),                                                  emit: json
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



        generate_input.py --maf_file ${inputMaf} \
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
            neoantigeninput: \$(echo \$(generate_input.py -v))
        END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def id = task.ext.prefix ?: "${meta.id}"
    def patientid =task.ext.cohort ?: "${meta.id}_patient"
    def cohort =task.ext.cohort ?: "${meta.id}_cohort"
    """

        touch ${patientid}_${id}_.json

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            neoantigeninput: \$(echo \$(generate_input.py -v))
        END_VERSIONS
    """
}
