include { GBCMS                       } from '../../../modules/msk/gbcms/main'
include { CUSTOM_FINGERPRINTVCFPARSER } from '../../../modules/msk/custom/fingerprintvcfparser/main'

workflow FINGERPRINT_GBCMS {

    take:
    ch_bam // channel: [ val(meta), [ bam ] ]
    ch_bai // channel: [ val(meta), [ bai ] ]
    ch_fp_vcf // channel: [ val(meta), [ vcf ] ]
    ch_fasta // channel: [ fasta ]
    ch_fastafai // channel: [ fastafai ]

    main:

    ch_versions = Channel.empty()

    GBCMS (
        ch_bam
            .combine(ch_bai, by:[0])
            .combine(ch_fp_vcf.map{ if (it.size() > 1){ it[1] } else { it }}.first())
            .map{ meta, bam, bai, vcf -> [meta, bam, bai, vcf, meta.id + ".fp.vcf" ] },
        ch_fasta.first(),
        ch_fastafai.first()
        //ch_fasta.view().map{ if (it[0] instanceof Map){ it[1] } else { it }}.first(),
        //ch_fastafai.view().map{ if (it[0] instanceof Map){ it[1] } else { it }}.first()
    )
    ch_versions = ch_versions.mix(GBCMS.out.versions.first())

    CUSTOM_FINGERPRINTVCFPARSER ( GBCMS.out.variant_file )
    ch_versions = ch_versions.mix(CUSTOM_FINGERPRINTVCFPARSER.out.versions.first())

    emit:
    fp_tsv   = CUSTOM_FINGERPRINTVCFPARSER.out.tsv // channel: [ val(meta), tsv ]
    versions = ch_versions                         // channel: [ versions.yml ]
}
