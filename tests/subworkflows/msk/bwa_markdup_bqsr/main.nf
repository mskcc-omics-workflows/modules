#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { BWA_INDEX } from '../../../../modules/nf-core/bwa/index/main.nf'
include { GATK4_CREATESEQUENCEDICTIONARY } from '../../../../modules/nf-core/gatk4/createsequencedictionary/main.nf'
include { SAMTOOLS_FAIDX } from '../../../../modules/nf-core/samtools/faidx/main.nf'
include { BWA_MARKDUP_BQSR } from '../../../../subworkflows/msk/bwa_markdup_bqsr/main.nf'

workflow test_bwa_markdup_bqsr {
    
    input = [
        [ id:'test', single_end:true ],
        [
            file(params.test_data['sarscov2']['illumina']['test_1_fastq_gz'], checkIfExists: true),
            file(params.test_data['sarscov2']['illumina']['test_2_fastq_gz'], checkIfExists: true)
        ]
    ]

    fasta = file(params.test_data['sarscov2']['genome']['genome_fasta'], checkIfExists: true)

    BWA_INDEX ( [[id: 'testfa'],fasta] )
    SAMTOOLS_FAIDX ( [[id: 'testfa'],fasta],[[],[]] )
    GATK4_CREATESEQUENCEDICTIONARY([[id: 'testfa'],fasta])

    BWA_MARKDUP_BQSR( 
        input,
        fasta,
        SAMTOOLS_FAIDX.out.fai.map{ it[1] }.first(),
        BWA_INDEX.out.index,
        GATK4_CREATESEQUENCEDICTIONARY.out.dict.map{ it[1] }.first(),
        [],
        [],
        false

        
    )
}
