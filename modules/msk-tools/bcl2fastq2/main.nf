process BCL2FASTQ {
    tag "DEMUX_${meta.id}"
    label 'process_low'

    if (params.enable_conda) {
        exit 1, "Conda environments cannot be used when using bcl2fastq. Please use docker or singularity containers."
    }
    container "ghcr.io/mskcc-omics-workflows/bcl2fastq:2.20.0.422"

    input:
    tuple val(meta), path(samplesheet), path(run_dir), path(casava_dir)

    output:
    tuple val(meta), path("${casava_dir}/**/*[!Undetermined]_S*_R?_00?.fastq.gz")      ,optional:true,emit: control_fastq
    tuple val(meta), path("${casava_dir}/**/**/*[!Undetermined]_S*_R?_00?.fastq.gz")   ,optional:true,emit: fastq
    tuple val(meta), path("${casava_dir}/Undetermined_S0*_R*_00?.fastq.gz")            ,emit: undetermined
    tuple val(meta), path("${casava_dir}/Reports")                                     ,emit: reports
    tuple val(meta), path("${casava_dir}/Stats")                                       ,emit: stats
    path("versions.yml")                                                            ,emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: '' //This is set in modules.config in workflow codebase
    def lane_split = meta.no_lane_split ? "--no-lane-splitting" : ""  //Check if lane split is necessary
    def ignore = ""
    meta.ignore_map.each {
        def ignore_str = it.value && ["bcls", "filter", "positions", "controls"].contains(it.key) ? " --ignore-missing-" + it.key : ""
        ignore = ignore + ignore_str
    } //Check if any thing needs to be ignored

    """
    bcl2fastq \\
        --output-dir ${casava_dir} \\
        --runfolder-dir ${run_dir} \\
        --sample-sheet ${samplesheet} \\
        --barcode-mismatches ${meta.mismatches} \\
        --use-bases-mask ${meta.base_mask} \\
        ${ignore} \\
        $lane_split \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bcl2fastq2: \$(bcl2fastq -V 2>&1 | grep -m 1 bcl2fastq | sed 's/^.*bcl2fastq v//')
    END_VERSIONS
    """
}
