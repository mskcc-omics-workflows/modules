include { CUSTOM_FINGERPRINTCOMBINE     as CUSTOM_FINGERPRINTCOMBINE_ALL      } from '../../../modules/msk/custom/fingerprintcombine/main'
include { CUSTOM_FINGERPRINTCOMBINE     as CUSTOM_FINGERPRINTCOMBINE_POOLS    } from '../../../modules/msk/custom/fingerprintcombine/main'
include { CUSTOM_FINGERPRINTCOMBINE     as CUSTOM_FINGERPRINTCOMBINE_PATIENTS } from '../../../modules/msk/custom/fingerprintcombine/main'
include { CUSTOM_FINGERPRINTCORRELATION as CUSTOM_FINGERPRINTCORRELATION_ALL      } from '../../../modules/msk/custom/fingerprintcorrelation/main'
include { CUSTOM_FINGERPRINTCORRELATION as CUSTOM_FINGERPRINTCORRELATION_POOLS    } from '../../../modules/msk/custom/fingerprintcorrelation/main'
include { CUSTOM_FINGERPRINTCORRELATION as CUSTOM_FINGERPRINTCORRELATION_PATIENTS } from '../../../modules/msk/custom/fingerprintcorrelation/main'
include { CUSTOM_FINGERPRINTMISLABELS   } from '../../../modules/msk/custom/fingerprintmislabels/main'

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
    CUSTOM_FINGERPRINTCOMBINE_ALL(
        ch_fp
            .map { meta, tsv ->
                [[id:"all"], tsv, meta.id, meta.genome ?: default_genome, meta.patient ?: meta.sample]
            }.groupTuple(by:[0]),
        ch_liftover_loci_mapping.first()
    )

    // Samples grouped by pool
    CUSTOM_FINGERPRINTCOMBINE_POOLS(
        ch_fp
            .combine(ch_pool.ifEmpty("").unique())
            .filter { meta, tsv, pool ->
                (pool == "") || (! pool) || (pool == meta.pool)
            }
            .map { meta, tsv, pool ->
                [[id:pool], tsv, meta.id, meta.genome ?: default_genome, meta.patient ?: meta.sample]
            }.groupTuple(by:[0]),
        ch_liftover_loci_mapping.first()
    )

    // Samples grouped by patient
    CUSTOM_FINGERPRINTCOMBINE_PATIENTS(
        ch_fp
            .filter { meta, tsv -> meta.patient != null }
            .combine(ch_patients.ifEmpty("").unique())
            .filter { meta, tsv, patient ->
                (patient == "") || (! patient) || (patient.toString() == meta.patient.toString())
            }
            .map { meta, tsv, patient ->
                [[id:meta.patient.toString()], tsv, meta.id, meta.genome ?: default_genome, meta.patient ?: meta.sample]
            }.groupTuple(by:[0]),
        ch_liftover_loci_mapping.first()
    )

    CUSTOM_FINGERPRINTCORRELATION_ALL(
        CUSTOM_FINGERPRINTCOMBINE_ALL.out.combined_fp_tsv,
        []
    )

    CUSTOM_FINGERPRINTCORRELATION_POOLS(
        CUSTOM_FINGERPRINTCOMBINE_POOLS.out.combined_fp_tsv,
        []
    )

    CUSTOM_FINGERPRINTCORRELATION_PATIENTS(
        CUSTOM_FINGERPRINTCOMBINE_PATIENTS.out.combined_fp_tsv,
        []
    )

    CUSTOM_FINGERPRINTMISLABELS(
        CUSTOM_FINGERPRINTCORRELATION_ALL.out.correlations_tab
            .join(CUSTOM_FINGERPRINTCORRELATION_ALL.out.observations_tab),
        ch_sample_sheet
            .filter { csv -> csv.readLines().size() >= 3 }
            .first()
    )

    emit:
    combined_fp_tsv_all      = CUSTOM_FINGERPRINTCOMBINE_ALL.out.combined_fp_tsv          // channel: [ val(meta), tsv ]
    combined_fp_tsv_pools    = CUSTOM_FINGERPRINTCOMBINE_POOLS.out.combined_fp_tsv        // channel: [ val(meta), tsv ]
    combined_fp_tsv_patients = CUSTOM_FINGERPRINTCOMBINE_PATIENTS.out.combined_fp_tsv     // channel: [ val(meta), tsv ]
    unexpected_match_pdf     = CUSTOM_FINGERPRINTMISLABELS.out.unexpected_match_pdf       // channel: [ val(meta), pdf ]
    unexpected_match_txt     = CUSTOM_FINGERPRINTMISLABELS.out.unexpected_match_txt       // channel: [ val(meta), txt ]
    unexpected_mismatch_pdf  = CUSTOM_FINGERPRINTMISLABELS.out.unexpected_mismatch_pdf   // channel: [ val(meta), pdf ]
    unexpected_mismatch_txt  = CUSTOM_FINGERPRINTMISLABELS.out.unexpected_mismatch_txt   // channel: [ val(meta), txt ]
}
