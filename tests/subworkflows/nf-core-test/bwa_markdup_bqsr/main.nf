#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { BWA_INDEX } from '../../../../../modules/nf-core/samtools/faidx/main.nf'
include { GATK4_CREATESEQUENCEDICTIONARY } from '../../../../../modules/nf-core/samtools/faidx/main.nf'
include { SAMTOOLS_FAIDX } from '../../../../../modules/nf-core/samtools/faidx/main.nf'
include { BWA_MARKDUP_BQSR } from '../../../../subworkflows/nf-core-test/bwa_markdup_bqsr/main.nf'

workflow test_bwa_markdup_bqsr {
    
    input = [
        [ id:'test', single_end:true ],
        [
            file(params.test_data['sarscov2']['illumina']['test_1_fastq_gz'], checkIfExists: true),
            file(params.test_data['sarscov2']['illumina']['test_2_fastq_gz'], checkIfExists: true)
        ]
    ]

    fasta = [
        [id: 'testfa'],
        file(params.test_data['sarscov2']['genome']['genome_fasta'], checkIfExists: true)
    ]

    BWA_INDEX ( fasta )
    SAMTOOLS_FAIDX ( fasta,[[],[]] )
    GATK4_CREATESEQUENCEDICTIONARY(fasta)

    BWA_MARKDUP_BQSR( 
        input,
        fasta,
        SAMTOOLS_FAIDX.out.fai,
        BWA_INDEX.out.index,
        GATK4_CREATESEQUENCEDICTIONARY.out.dict,
        [],
        [],
        false

        
    )
}
