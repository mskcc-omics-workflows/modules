#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { GETBASECOUNTMULTISAMPLE as GETBASECOUNTMULTISAMPLE_MAF} from '../../../../modules/msk-tools/getbasecountmultisample/main.nf'
include { GETBASECOUNTMULTISAMPLE as GETBASECOUNTMULTISAMPLE_VCF} from '../../../../modules/msk-tools/getbasecountmultisample/main.nf'

File out_dir = new File("output")
if (!out_dir.exists()) {
    out_dir.mkdirs()
}


workflow test_getbasecountmultisample_maf {
    
    input = [
        [ id:'test' ], // meta map
        file(params.fasta, checkIfExists: true),
        file(params.fastafai, checkIfExists: true),
        file(params.bam, checkIfExists: true),
        file(params.bambai, checkIfExists: true),
        file("tools-test-dataset/getbasecountmultisample/chr22.maf"),
        params.sample,
        // customize test specific parameters here
        "test.maf",
        [args: '--omaf']
        
    ]
    GETBASECOUNTMULTISAMPLE_MAF ( input )
}


workflow test_getbasecountmultisample_vcf {
    
    input = [
        [ id:'test' ], // meta map
        file(params.fasta, checkIfExists: true),
        file(params.fastafai, checkIfExists: true),
        file(params.bam, checkIfExists: true),
        file(params.bambai, checkIfExists: true),
        file("tools-test-dataset/getbasecountmultisample/chr22.vcf"),
        params.sample,
        // customize test specific parameters here
        "test.vcf",
        [args: '']
        
    ]
    GETBASECOUNTMULTISAMPLE_VCF ( input )
}