#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { BCL2FASTQ } from '../../../modules/bcl2fastq2/main.nf'

// Deal with output dir
File out_dir = new File(params.casava_dir)
if (!out_dir.exists()) {
    out_dir.mkdirs()
}

input = [
    [ id:'test',
      run:'220726_M07206_0107_000000000-KGBL6',
      mismatches: '1',
      base_mask: 'y151,i8,i8,y151',
      no_lane_split: false,
      ignore_map: [
        bcls: true,
        filter: true,
        positions: true,
        controls: true
      ]], // meta map
        
    file(params.samplesheet, checkIfExists: true),
    file(params.run_dir, checkIfExists: true),
    file(out_dir, checkIfExists: true)
]


workflow test_bcl2fastq2 {

    BCL2FASTQ ( input )
}

workflow {
    test_bcl2fastq2 ()
}
//nextflow run main.nf -process.echo -profile docker
