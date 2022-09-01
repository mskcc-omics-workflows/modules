#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { BCL2FASTQ } from '../main.nf'

workflow test_bcl2fastq2 {
    input = [
        [ id:['test'],
          run:['220726_M07206_0107_000000000-KGBL6'],
          pool:['test'],
          mismatches: ['1'],
          base_mask: ['y151,i8,i8,y151'],
          no_lane_split: [""]],
          //no_lane_split: ["--no-lane-splitting"]], // meta map
          
        file(params.samplesheet, checkIfExists: true),
        params.run_dir,
        params.casava_dir
    ]

    BCL2FASTQ ( input )
}

workflow {
    test_bcl2fastq2 ()
}