#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { GBCMS } from '../../../../modules/msk/gbcms/main.nf'

workflow test_gbcms_stub {
    
    input = [
        [ id:'test', sample:'sample' ], // meta map
        [],
        [],
        [],
        "variant_file.maf"
        
    ]

    GBCMS ( input, [], [])
}

workflow test_gbcms {
    
    input = [
        [ id:'test', sample:'197' ], // meta map
        file(params.test_data['sarscov2']['illumina']['test_single_end_sorted_bam'], checkIfExists: true),
        file(params.test_data['sarscov2']['illumina']['test_single_end_sorted_bam_bai'], checkIfExists: true),
        file(params.test_data['sarscov2']['illumina']['test_vcf'], checkIfExists: true),
        "variant_file.vcf"
        
    ]
    fasta = file(params.test_data['sarscov2']['genome']['genome_fasta'], checkIfExists: true)
    fastafai = file(params.test_data['sarscov2']['genome']['genome_fasta_fai'], checkIfExists: true)

    GBCMS ( input, fasta, fastafai)
}