process PRE_BCL2FASTQ {
    tag "Pre_bcl2fastq"
    label "process_high"

    if (params.enable_conda) {
        exit 1, "Conda environments cannot be used when using pre-bcl2fastq. Please use docker or singularity containers."
    }
    container "mpathdms/pre-bcl2fastq:0.1.4"

    input:
    tuple path(runinfo), path(runparams), path(samplesheet)

    output:
    path "*.csv"           , emit: meta_file

    script:
    """
    python /create_meta.py \\
        -i ${runinfo} \\
        -r ${runparams} \\
        -s ${samplesheet} \\
        -o meta.csv
    """
}
