
include { CUSTOM_FINGERPRINTCOMBINE } from '../../../modules/msk/custom/fingerprintcombine/main'

workflow FINGERPRINT_GBCMS_BATCH {

    take:
    ch_fp // channel: [ val(meta), [ bam ] ]
    ch_liftover_loci_mapping // channel: [ liftover_loci_mapping ]

    main:

    ch_versions = Channel.empty()


    CUSTOM_FINGERPRINTCOMBINE(
        ch_fp
            .map{ meta, tsv -> ["placeholder",tsv, meta.id, "hg19"] }
            .groupTuple(by:[0])
            .map{ placeholder, tsv, sampleid, genome -> [tsv, sampleid, genome] },
        ch_liftover_loci_mapping.first()
    )
    ch_versions = ch_versions.mix(CUSTOM_FINGERPRINTCOMBINE.out.versions.first())

    emit:
    combined_fp_tsv = CUSTOM_FINGERPRINTCOMBINE.out.combined_fp_tsv // channel: [ val(meta), [ bam ] ]
    versions        = ch_versions                                   // channel: [ versions.yml ]
}
