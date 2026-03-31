include { GBCMS                           } from '../../../modules/msk/gbcms/main'
include { FINGERPRINT_VCFPARSER           } from '../../../modules/msk/fingerprint/vcfparser/main'
include { FINGERPRINT_CONTAMINATION       } from '../../../modules/msk/fingerprint/contamination/main'

workflow FINGERPRINT_GBCMS {

    take:
    ch_bam // channel: [ val(meta), [ bam ] ]
    ch_bai // channel: [ val(meta), [ bai ] ]
    ch_fp_tsv // channel: [ val(meta), [ tsv ] ]
    ch_fp_loci_vcf // channel: [ val(meta), [ vcf ] ]
    ch_fasta // channel: [ fasta ]
    ch_fastafai // channel: [ fastafai ]

    main:


    GBCMS(
        ch_bam
            .combine(ch_bai, by:[0])
            .combine(ch_fp_loci_vcf.map{ if ( [it].flatten().size() > 1){ it[1] } else { it }}.first())
            .map{ meta, bam, bai, vcf -> [ meta, bam, bai, vcf, meta.id + ".fp.vcf" ] },
        ch_fasta.first(),
        ch_fastafai.first()
    )

    FINGERPRINT_VCFPARSER ( GBCMS.out.variant_file )

    all_fps = FINGERPRINT_VCFPARSER.out.tsv.mix(ch_fp_tsv)

    paired_fps = all_fps
        .filter{ meta, tsv -> meta.case_id != null && meta.control_id != null && meta.id == meta.case_id }
        .combine(all_fps)
        .filter{ meta1, fp1, meta2, fp2 ->
            meta1.control_id == meta2.id
        }.map{ meta1, fp1, meta2, fp2 ->
            [ meta1, fp1, fp2]
        }

    unpaired_fps = all_fps
        .filter{ meta, tsv -> ! meta.control_id }
        .map{ meta, tsv -> [ meta, tsv, [] ] }

    FINGERPRINT_CONTAMINATION ( paired_fps.mix(unpaired_fps) )

    emit:
    fp_tsv_from_bam   = FINGERPRINT_VCFPARSER.out.tsv                   // channel: [ val(meta), tsv ]
    fp_tsv            = all_fps                                               // channel: [ val(meta), tsv ]
    contamination_tsv = FINGERPRINT_CONTAMINATION.out.contamination_tsv // channel: [ val(meta), contamination_tsv ]

}
