include { FINGERPRINT_COMBINE           as FINGERPRINT_COMBINE_ALL            } from '../../../modules/msk/fingerprint/combine/main'
include { FINGERPRINT_COMBINE           as FINGERPRINT_COMBINE_POOLS          } from '../../../modules/msk/fingerprint/combine/main'
include { FINGERPRINT_COMBINE           as FINGERPRINT_COMBINE_PATIENTS       } from '../../../modules/msk/fingerprint/combine/main'
include { FINGERPRINT_CORRELATION       as FINGERPRINT_CORRELATION_ALL           } from '../../../modules/msk/fingerprint/correlation/main'
include { FINGERPRINT_CORRELATION       as FINGERPRINT_CORRELATION_POOLS         } from '../../../modules/msk/fingerprint/correlation/main'
include { FINGERPRINT_CORRELATION       as FINGERPRINT_CORRELATION_PATIENTS      } from '../../../modules/msk/fingerprint/correlation/main'
include { FINGERPRINT_MISLABELS         } from '../../../modules/msk/fingerprint/mislabels/main'

workflow FINGERPRINT_GBCMS_BATCH {

    take:
    ch_fp                    // channel: [ val(meta), tsv ]
    ch_liftover_loci_mapping // channel: [ liftover_loci_mapping ]
    default_genome
    ch_pool                  // channel: [ poolid ]
    ch_patients              // channel: [ patientid ]

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

    // All samples combined into a single group
    FINGERPRINT_COMBINE_ALL(
        ch_fp
            .map { meta, tsv ->
                [[id:"all"], tsv, meta.id, meta.genome ?: default_genome, meta.patient ?: meta.sample]
            }.groupTuple(by:[0]),
        ch_liftover_loci_mapping.first()
    )

    // Samples grouped by pool
    FINGERPRINT_COMBINE_POOLS(
        ch_fp
            .combine(ch_pool.unique())
            .filter { meta, tsv, pool ->
                pool == meta.pool
            }
            .map { meta, tsv, pool ->
                [[id:pool], tsv, meta.id, meta.genome ?: default_genome, meta.patient ?: meta.sample]
            }.groupTuple(by:[0]),
        ch_liftover_loci_mapping.first()
    )

    // Samples grouped by patient
    FINGERPRINT_COMBINE_PATIENTS(
        ch_fp
            .combine(ch_patients.unique())
            .filter { meta, tsv, patient ->
                patient.toString() == meta.patient.toString()
            }.map { meta, tsv, patient ->
                [[id:meta.patient.toString()], tsv, meta.id, meta.genome ?: default_genome, meta.patient ?: meta.sample]
            }.groupTuple(by:[0]),
        ch_liftover_loci_mapping.first()
    )

    FINGERPRINT_CORRELATION_ALL(
        FINGERPRINT_COMBINE_ALL.out.combined_fp_tsv,
        []
    )

    FINGERPRINT_CORRELATION_POOLS(
        FINGERPRINT_COMBINE_POOLS.out.combined_fp_tsv,
        []
    )

    FINGERPRINT_CORRELATION_PATIENTS(
        FINGERPRINT_COMBINE_PATIENTS.out.combined_fp_tsv,
        []
    )

    FINGERPRINT_MISLABELS(
        FINGERPRINT_CORRELATION_ALL.out.correlations_tab
            .join(FINGERPRINT_CORRELATION_ALL.out.observations_tab),
        ch_sample_sheet
            .filter { csv -> csv.readLines().size() >= 3 }
            .first()
    )

    emit:
    combined_fp_tsv_all      = FINGERPRINT_COMBINE_ALL.out.combined_fp_tsv          // channel: [ val(meta), tsv ]
    combined_fp_tsv_pools    = FINGERPRINT_COMBINE_POOLS.out.combined_fp_tsv        // channel: [ val(meta), tsv ]
    combined_fp_tsv_patients = FINGERPRINT_COMBINE_PATIENTS.out.combined_fp_tsv     // channel: [ val(meta), tsv ]
    unexpected_match_pdf     = FINGERPRINT_MISLABELS.out.unexpected_match_pdf       // channel: [ val(meta), pdf ]
    unexpected_match_txt     = FINGERPRINT_MISLABELS.out.unexpected_match_txt       // channel: [ val(meta), txt ]
    unexpected_mismatch_pdf  = FINGERPRINT_MISLABELS.out.unexpected_mismatch_pdf   // channel: [ val(meta), pdf ]
    unexpected_mismatch_txt  = FINGERPRINT_MISLABELS.out.unexpected_mismatch_txt   // channel: [ val(meta), txt ]
}
