process BCL2FASTQ {
    tag "DEMUX_${meta.id}"
    //label 'process_medium'

    if (params.enable_conda) {
        exit 1, "Conda environments cannot be used when using bcl2fastq. Please use docker or singularity containers."
    }
    container "mpathdms/bcl2fastq:2.20.0.422"

    input:
    tuple val(meta), path(samplesheet), path(run_dir), path(casava_dir)

    output:
    tuple val(meta), path("${casava_dir}/**/*[!Undetermined]_S*_R?_00?.fastq.gz")      ,optional:true,emit: control_fastq
    tuple val(meta), path("${casava_dir}/**/**/*[!Undetermined]_S*_R?_00?.fastq.gz")   ,optional:true,emit: fastq
    tuple val(meta), path("${casava_dir}/Undetermined_S0*_R*_00?.fastq.gz")            ,emit: undetermined
    tuple val(meta), path("${casava_dir}/Reports")                                     ,emit: reports
    tuple val(meta), path("${casava_dir}/Stats")                                       ,emit: stats

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: '' //This is set in modules.config in workflow codebase
    def lane_split = meta.no_lane_split.join('') ?: ""

    """
    bcl2fastq \\
        --output-dir ${casava_dir} \\
        --runfolder-dir ${run_dir} \\
        --sample-sheet ${samplesheet} \\
        --barcode-mismatches ${meta.mismatches.join('')} \\
        --use-bases-mask ${meta.base_mask.join('')} \\
        --ignore-missing-bcls \\
        --ignore-missing-filter \\
        --ignore-missing-positions \\
        --ignore-missing-controls \\
        $lane_split
        $args
    """
}
