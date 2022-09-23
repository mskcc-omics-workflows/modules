#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { MERGE } from '../../../modules/merge/main.nf'

ch_test_data = Channel.fromFilePairs( '../../../tools-test-dataset/merge/Sample*_L00{1,2}_R1_001.fastq.gz')
    .flatten()
    .toList()
    .set { ch_pair_data }
meta = [ id:'test', sample_name:'', read:'' ] // meta map

workflow test_merge {
    
    ch_pair_data
        .map { sample_name, fastq_1, fastq_2 ->
                meta.read = fastq_1.toString().split('_')[-2].replace("R", "")
                meta.sample_name = sample_name
                [ meta, fastq_1, fastq_2 ] }
        .set { input }

    MERGE ( input )
}

workflow {
    test_merge()
}