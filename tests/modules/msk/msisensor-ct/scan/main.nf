#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { MSISENSOR_CT_SCAN } from '../../../../modules/msk/msisensor-ct/scan/main.nf'

workflow test_msisensor_ct {

    input = [
        [ id:'test' ], // meta map
        []
    ]

    MSISENSOR_CT_SCAN ( input )
}

workflow test_msisensor_ct_data {

    input = [
        [ id:'test' ], // meta map
        file(params.fasta, checkIfExists: true),
        file("/home/charalk/Homo_sapiens_assembly19.fasta"),
        params.sample,
        // customize test specific parameters here
        "fasta",
        [args: '--fa']

    ]

    MSISENSOR_CT_SCAN ( input )
}