#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { MSISENSOR-CT } from '../../../../modules/msk/msisensor-ct/scan/main.nf'

workflow test_msisensor_ct {

    input = [
        [ id:'test' ], // meta map
        [],
        [],
        [],
        [],
        [],
        params.sample,
        // customize test specific parameters here
        "fasta",
        [args: '--fa']

    ]

    MSISENSOR-CT ( input )
}

workflow test_msisensor_ct_data {

    input = [
        [ id:'test' ], // meta map
        file(params.fasta, checkIfExists: true),
        file("/home/buehlere/access_nextflow/getbasecountmultisample/chr22.maf"),
        params.sample,
        // customize test specific parameters here
        "fasta",
        [args: '--fa']

    ]

    MSISENSOR-CT ( input )
}