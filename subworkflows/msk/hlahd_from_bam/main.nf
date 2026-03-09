include { SAMTOOLS_VIEW  } from '../../../modules/nf-core/samtools/view/main'
include { GATK4_REVERTSAM } from '../../../modules/nf-core/gatk4/revertsam/main'
include { SAMTOOLS_FASTQ } from '../../../modules/nf-core/samtools/fastq/main'
include { HLAHD          } from '../../../modules/msk/hlahd/main'

workflow HLAHD_FROM_BAM {

    take:
    ch_bam           // channel: [ val(meta), path(bam), path(bai) ]
    skip_revert_sam  // val: Boolean

    main:

    ch_versions = Channel.empty()

    //
    // MODULE: Extract HLA region from BAM using samtools view.
    // The caller configures the region to extract via ext.args in modules.config,
    // e.g. ext.args = '-b chr6:28000000-34000000'
    //
    SAMTOOLS_VIEW(
        ch_bam,
        [[],[]],
        [],
        []
    )
    ch_versions = ch_versions.mix(SAMTOOLS_VIEW.out.versions.first())

    //
    // Optional: Revert base quality score recalibration with GATK4 RevertSam.
    // Set skip_revert_sam = true when the BAM has no BQSR applied (e.g. already
    // in OQ-restored state, or produced by a tool that does not perform BQSR).
    //
    if (!skip_revert_sam) {

        GATK4_REVERTSAM(
            SAMTOOLS_VIEW.out.bam
        )
        ch_versions = ch_versions.mix(GATK4_REVERTSAM.out.versions.first())
        ch_for_fastq = GATK4_REVERTSAM.out.bam

    } else {

        ch_for_fastq = SAMTOOLS_VIEW.out.bam

    }

    //
    // MODULE: Convert BAM to paired FASTQ files.
    // SAMTOOLS_FASTQ emits .out.fastq as [ meta, [fq1, fq2] ]; unpack into
    // separate paths so HLAHD receives the three-element tuple it expects.
    //
    SAMTOOLS_FASTQ(
        ch_for_fastq,
        false
    )
    ch_versions = ch_versions.mix(SAMTOOLS_FASTQ.out.versions.first())

    ch_fastq_for_hlahd = SAMTOOLS_FASTQ.out.fastq
        .map { meta, fastqs ->
            def (fq1, fq2) = fastqs
            [meta, fq1, fq2]
        }

    //
    // MODULE: Run HLA-HD to call HLA alleles from paired FASTQ files.
    //
    HLAHD(
        ch_fastq_for_hlahd
    )
    ch_versions = ch_versions.mix(HLAHD.out.versions.first())

    emit:
    result           = HLAHD.out.result           // channel: [ val(meta), path(result/*_final.result.txt) ]
    result_per_locus = HLAHD.out.result_per_locus // channel: [ val(meta), path(result/*_*.est.txt) ]
    versions         = ch_versions                // channel: [ path(versions.yml) ]
}
