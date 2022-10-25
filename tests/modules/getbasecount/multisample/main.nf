#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { GETBASECOUNT_MULTISAMPLE } from '../../../../modules/getbasecount/multisample/main.nf'


input = [
    [ id:'test' ], // meta map
    file(params.fasta, checkIfExists: true),
    file(params.fastafai, checkIfExists: true),
    file(params.bam, checkIfExists: true),
    file(params.bambai, checkIfExists: true),
    file(params.vcf, checkIfExists: true),
    params.sample,
    params.fragment_count,
    params.filter_duplicate, 
    params.maq
    
]

workflow test_getbasecount_multisample {
    

    GETBASECOUNT_MULTISAMPLE ( input )
}
