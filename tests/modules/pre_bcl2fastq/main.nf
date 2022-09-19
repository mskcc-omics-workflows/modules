#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PRE_BCL2FASTQ } from '../../../modules/pre_bcl2fastq/main.nf'

workflow test_pre_bcl2fastq {
    input = [
        file(params.runinfo, checkIfExists: true),
        file(params.runparams, checkIfExists: true),
        file(params.samplesheet, checkIfExists: true)
    ]

    PRE_BCL2FASTQ ( input )
}

workflow {
    test_pre_bcl2fastq ()
}