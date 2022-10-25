#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { GETBASECOUNTS_MULTISAMPLE } from '../../../../modules/getbasecounts/multisample/main.nf'

workflow test_getbasecounts_multisample {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true)
    ]

    GETBASECOUNTS_MULTISAMPLE ( input )
}
