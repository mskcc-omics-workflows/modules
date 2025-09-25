include { GBCMS                           } from '../../../modules/msk/gbcms/main'
include { CUSTOM_FINGERPRINTVCFPARSER     } from '../../../modules/msk/custom/fingerprintvcfparser/main'
include { CUSTOM_FINGERPRINTCONTAMINATION } from '../../../modules/msk/custom/fingerprintcontamination/main'

workflow FINGERPRINT_GBCMS {

    take:
    //ch_bam // channel: [ val(meta), [ bam ] ]
    //ch_bai // channel: [ val(meta), [ bai ] ]
    //ch_fp_loci_vcf // channel: [ val(meta), [ vcf ] ]
    //ch_fasta // channel: [ fasta ]
    //ch_fastafai // channel: [ fastafai ]
    ch_bam // channel: [ val(meta), [ bam ] ]
    ch_bai // channel: [ val(meta), [ bai ] ]
    ch_fp_tsv // channel: [ val(meta), [ tsv ] ]
    ch_fp_loci_vcf // channel: [ val(meta), [ vcf ] ]
    ch_liftover_loci_mapping // channel: [ liftover_loci_mapping ]
    ch_fasta // channel: [ fasta ]
    ch_fastafai // channel: [ fastafai ]

    main:

    ch_versions = Channel.empty()

    GBCMS (
        ch_bam
            .combine(ch_bai, by:[0])
            .combine(ch_fp_loci_vcf.map{ if (it.size() > 1){ it[1] } else { it }}.first())
            .map{ meta, bam, bai, vcf -> [meta, bam, bai, vcf, meta.id + ".fp.vcf" ] },
        ch_fasta.first(),
        ch_fastafai.first()
        //ch_fasta.view().map{ if (it[0] instanceof Map){ it[1] } else { it }}.first(),
        //ch_fastafai.view().map{ if (it[0] instanceof Map){ it[1] } else { it }}.first()
    )
    ch_versions = ch_versions.mix(GBCMS.out.versions.first())

    CUSTOM_FINGERPRINTVCFPARSER ( GBCMS.out.variant_file )
    ch_versions = ch_versions.mix(CUSTOM_FINGERPRINTVCFPARSER.out.versions.first())

    all_fps = CUSTOM_FINGERPRINTVCFPARSER.out.tsv.mix(ch_fp_tsv)

    paired_fps = all_fps
        .filter{ meta, tsv -> meta.case_id != null && meta.control_id != null && meta.id == meta.case_id }
        .combine(all_fps.out.tsv)
        .filter{ meta1, fp1, meta2, fp2 ->
            meta1.control_id == meta2.id
        }.map{ meta1, fp1, meta2, fp2 ->
            [ meta1, fp1, fp2]
        }

    unpaired_fps = all_fps
        .filter{ meta, tsv -> meta.id != meta.case_id || meta.control_id == null }
        .map{ meta, tsv -> [ meta, tsv, null ] }

    CUSTOM_FINGERPRINTCONTAMINATION ( paired_fps.mix(unpaired_fps) )
    ch_versions = ch_versions.mix(CUSTOM_FINGERPRINTCONTAMINATION.out.versions.first())


    emit:
    fp_tsv            = CUSTOM_FINGERPRINTVCFPARSER.out.tsv                   // channel: [ val(meta), tsv ]
    contamination_tsv = CUSTOM_FINGERPRINTCONTAMINATION.out.contamination_tsv // channel: [ val(meta), contamination_tsv ]
    versions          = ch_versions                                           // channel: [ versions.yml ]
}
