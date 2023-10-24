#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { GBCMS } from '../../../../modules/msk/gbcms/main.nf'

workflow test_gbcms {
    
    input = [
        [ id:'test' ], // meta map
        [],
        [],
        [],
        [],
        [],
        params.sample,
        // customize test specific parameters here
        "variant_file.maf",
        [args: '--omaf']
        
    ]

    GBCMS ( input )
}

workflow test_gbcms_data {
    
    input = [
        [ id:'test' ], // meta map
        file(params.fasta, checkIfExists: true),
        file(params.fastafai, checkIfExists: true),
        file(params.bam, checkIfExists: true),
        file(params.bambai, checkIfExists: true),
        file(params.variant, checkIfExists: true),
        params.sample,
        // customize test specific parameters here
        "variant_file.maf"
        
    ]

    GBCMS ( input )
}