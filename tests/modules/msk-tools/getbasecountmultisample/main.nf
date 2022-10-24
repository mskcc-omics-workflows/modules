#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { GETBASECOUNTMULTISAMPLE } from '../../../../modules/msk-tools/getbasecountmultisample/main.nf'

File out_dir = new File("output")
if (!out_dir.exists()) {
    out_dir.mkdirs()
}

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
    params.maq, 
    
]

workflow test_getbasecountmultisample {
    

    GETBASECOUNTMULTISAMPLE ( input )
}
