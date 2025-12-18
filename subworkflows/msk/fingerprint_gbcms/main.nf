include { GBCMS                           } from '../../../modules/msk/gbcms/main'
include { CUSTOM_FINGERPRINTVCFPARSER     } from '../../../modules/msk/custom/fingerprintvcfparser/main'
include { CUSTOM_FINGERPRINTCONTAMINATION } from '../../../modules/msk/custom/fingerprintcontamination/main'
include { FINGERPRINT_GBCMS_BATCH         } from '../fingerprint_gbcms_batch/main'

workflow FINGERPRINT_GBCMS {

    take:
    ch_bam // channel: [ val(meta), [ bam ] ]
    ch_bai // channel: [ val(meta), [ bai ] ]
    ch_fp_tsv // channel: [ val(meta), [ tsv ] ]
    ch_fp_loci_vcf // channel: [ val(meta), [ vcf ] ]
    ch_liftover_loci_mapping // channel: [ liftover_loci_mapping ]
    ch_fasta // channel: [ fasta ]
    ch_fastafai // channel: [ fastafai ]
    default_genome // channel: [ genome ]
    run_correlation

    main:

    println ch_fp_loci_vcf.getClass()
    println ch_fasta.getClass()

    GBCMS(
        ch_bam
            .combine(ch_bai, by:[0])
            .combine(ch_fp_loci_vcf.map{ if ( [it].flatten().size() > 1){ it[1] } else { it }}.first())
            .map{ meta, bam, bai, vcf -> [ meta, bam, bai, vcf, meta.id + ".fp.vcf" ] }.view(),
        ch_fasta.first(),
        ch_fastafai.first()
        //ch_fasta.view().map{ if (it[0] instanceof Map){ it[1] } else { it }}.first(),
        //ch_fastafai.view().map{ if (it[0] instanceof Map){ it[1] } else { it }}.first()
    )



    CUSTOM_FINGERPRINTVCFPARSER ( GBCMS.out.variant_file )

    all_fps = CUSTOM_FINGERPRINTVCFPARSER.out.tsv.mix(ch_fp_tsv)

    paired_fps = all_fps
        .filter{ meta, tsv -> meta.case_id != null && meta.control_id != null && meta.id == meta.case_id }
        .combine(all_fps)
        .filter{ meta1, fp1, meta2, fp2 ->
            meta1.control_id == meta2.id
        }.map{ meta1, fp1, meta2, fp2 ->
            [ meta1, fp1, fp2]
        }

    unpaired_fps = all_fps
        .filter{ meta, tsv -> meta.id != meta.case_id || meta.control_id == null }
        .map{ meta, tsv -> [ meta, tsv, [] ] }

    CUSTOM_FINGERPRINTCONTAMINATION ( paired_fps.mix(unpaired_fps).view() )

    if (run_correlation) {
        FINGERPRINT_GBCMS_BATCH (
            all_fps,
            ch_liftover_loci_mapping,
            default_genome
        )
    } else {
        FINGERPRINT_GBCMS_BATCH.out.combined_fp_tsv = Channel.empty()
    }

    emit:
    fp_tsv            = CUSTOM_FINGERPRINTVCFPARSER.out.tsv                   // channel: [ val(meta), tsv ]
    contamination_tsv = CUSTOM_FINGERPRINTCONTAMINATION.out.contamination_tsv // channel: [ val(meta), contamination_tsv ]
    combined_fp_tsv   = FINGERPRINT_GBCMS_BATCH.out.combined_fp_tsv           // channel: [ tsv ]

}
