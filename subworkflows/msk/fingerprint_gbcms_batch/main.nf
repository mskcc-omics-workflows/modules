include { CUSTOM_FINGERPRINTCOMBINE     } from '../../../modules/msk/custom/fingerprintcombine/main'
include { CUSTOM_FINGERPRINTCORRELATION } from '../../../modules/msk/custom/fingerprintcorrelation/main'
include { CUSTOM_FINGERPRINTMISLABELS   } from '../../../modules/msk/custom/fingerprintmislabels/main'

workflow FINGERPRINT_GBCMS_BATCH {

    take:
    ch_fp                    // channel: [ val(meta), [ bam ] ]
    ch_liftover_loci_mapping // channel: [ liftover_loci_mapping ]
    default_genome
    ch_pool                  // channel: [ poolid ]

    main:

    ch_sample_sheet = ch_fp
        .filter { meta, tsv -> meta.patient != null }
        .map { meta, tsv ->
            def is_donor = meta.is_donor != null ? meta.is_donor : false
            "${meta.sample},${meta.patient},${is_donor}\n"
        }
        .collectFile(
            name: 'sample_sheet.csv',
            seed: 'sample,patient,is_donor\n',
            newLine: false,
            sort: true
        )

    CUSTOM_FINGERPRINTCOMBINE(
        ch_fp
            .combine(ch_pool.ifEmpty("").unique())
            .filter{meta, tsv, pool ->
                (pool == "") || (! pool) || (pool == meta.pool)
            }
            .map{ meta, tsv, pool ->
                def meta2 = [id:pool]
                [meta2, tsv, meta.id, meta.genome ?: default_genome, meta.patient ?: meta.sample ]
            }.groupTuple(by:[0]),
        ch_liftover_loci_mapping.first()
    )

    CUSTOM_FINGERPRINTCORRELATION(
        CUSTOM_FINGERPRINTCOMBINE.out.combined_fp_tsv,
        []
    )

    CUSTOM_FINGERPRINTMISLABELS(
        CUSTOM_FINGERPRINTCORRELATION.out.correlations_tab
            .join(CUSTOM_FINGERPRINTCORRELATION.out.observations_tab),
        ch_sample_sheet
            .filter { csv -> csv.readLines().size() >= 3 }
            .first()
    )

    emit:
    combined_fp_tsv        = CUSTOM_FINGERPRINTCOMBINE.out.combined_fp_tsv          // channel: [ val(meta), tsv ]
    unexpected_match_pdf   = CUSTOM_FINGERPRINTMISLABELS.out.unexpected_match_pdf   // channel: [ val(meta), pdf ]
    unexpected_match_txt   = CUSTOM_FINGERPRINTMISLABELS.out.unexpected_match_txt   // channel: [ val(meta), txt ]
    unexpected_mismatch_pdf = CUSTOM_FINGERPRINTMISLABELS.out.unexpected_mismatch_pdf // channel: [ val(meta), pdf ]
    unexpected_mismatch_txt = CUSTOM_FINGERPRINTMISLABELS.out.unexpected_mismatch_txt // channel: [ val(meta), txt ]
}
