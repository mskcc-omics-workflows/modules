include { CUSTOM_FINGERPRINTCOMBINE     } from '../../../modules/msk/custom/fingerprintcombine/main'
include { CUSTOM_FINGERPRINTCORRELATION } from '../../../modules/msk/custom/fingerprintcorrelation/main'

workflow FINGERPRINT_GBCMS_BATCH {

    take:
    ch_fp                    // channel: [ val(meta), [ bam ] ]
    ch_liftover_loci_mapping // channel: [ liftover_loci_mapping ]
    default_genome
    pool                     // channel: [ poolid ]

    main:

    CUSTOM_FINGERPRINTCOMBINE(
        ch_fp
            .combine(pool.ifEmpty("").unique())
            .filter{meta, tsv, pool ->
                (pool == "") || (! pool) || (pool == meta.pool)
            }
            .map{ meta, tsv,pool ->
                def meta2 = [id:pool]
                [meta2, tsv, meta.id, meta.genome ?: default_genome, meta.patient ?: meta.sample ]
            }.groupTuple(by:[0]),
        ch_liftover_loci_mapping.first()
    )

    CUSTOM_FINGERPRINTCORRELATION(
        CUSTOM_FINGERPRINTCOMBINE.out.combined_fp_tsv,
        []

    )

    emit:
    combined_fp_tsv = CUSTOM_FINGERPRINTCOMBINE.out.combined_fp_tsv // channel: [ val(meta), [ bam ] ]
}
