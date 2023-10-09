include { BWA_MEM                      } from '../../../modules/mskcc/bwa/mem/main'
include { GATK4_MARKDUPLICATES         } from '../../../modules/mskcc/gatk4/markduplicates/main'
include { GATK4_MARKDUPLICATES_SPARK   } from '../../../modules/mskcc/gatk4/markduplicatesspark/main'
include { GATK4_APPLYBQSR              } from '../../../modules/mskcc/gatk4/applybqsr/main'
include { GATK4_APPLYBQSR_SPARK        } from '../../../modules/mskcc/gatk4/applybqsrspark/main'
include { GATK4_BASERECALIBRATOR       } from '../../../modules/mskcc/gatk4/baserecalibrator/main'
include { GATK4_BASERECALIBRATOR_SPARK } from '../../../modules/mskcc/gatk4/baserecalibratorspark/main'
include { SAMTOOLS_INDEX               } from '../../../modules/mskcc/samtools/index/main'


workflow BWA_MARKDUP_BQSR {
    take:
        reads
        fasta
        fai
        bwa_index
        dict
        known_sites
        known_sites_tbi
        spark // true, false

    main:

        ch_versions = Channel.empty()

        // run once for each pair of reads
        BWA_MEM(
            reads,
            bwa_index,
            true
        )
        ch_versions = ch_versions.mix(BWA_MEM.out.versions.first())

        grouped_bam_ch = 
            BWA_MEM.out.bam
                .map{meta, bam ->
                    def new_meta = meta - meta.subMap(['read_group'])
                    [ new_meta, bam ]
                }.groupTuple(by:0)

        if (spark){
            GATK4_MARKDUPLICATES_SPARK(
                grouped_bam_ch,
                fasta,
                fai
            )
            GATK4_BASERECALIBRATOR_SPARK(
                GATK4_MARKDUPLICATES_SPARK.out.output,
                fasta,
                fai,
                dict,
                known_sites,
                known_sites_tbi
            )
            GATK4_APPLYBQSR_SPARK(
                GATK4_MARKDUPLICATES_SPARK.out.output
                    .join(GATK4_MARKDUPLICATES_SPARK.out.bam_index)
                    .join(GATK4_BASERECALIBRATOR_SPARK.out.table)
                    .map{meta, bam, bai, table ->
                        [ meta, bam, bai, table, [] ] // what is intervals? 
                    },
                fasta,
                fai,
                dict
            )
            bqsr_bam = GATK4_APPLYBQSR_SPARK.out.bam

        } else {
            GATK4_MARKDUPLICATES(
                grouped_bam_ch,
                fasta,
                fai
            )
            GATK4_BASERECALIBRATOR(
                GATK4_MARKDUPLICATES.out.bam,
                fasta,
                fai,
                dict,
                known_sites,
                known_sites_tbi
            )
            GATK4_APPLYBQSR(
                GATK4_MARKDUPLICATES.out.bam
                    .join(GATK4_MARKDUPLICATES.out.bai)
                    .join(GATK4_BASERECALIBRATOR.out.table)
                    .map{meta, bam, bai, table ->
                        [ meta, bam, bai, table, [] ] // what is intervals? 
                    },
                fasta,
                fai,
                dict
            )
            bqsr_bam = GATK4_APPLYBQSR.out.bam
            // bqsr_bai = GATK4_APPLYBQSR.out.bai
        }

        SAMTOOLS_INDEX(bqsr_bam)
        ch_versions = ch_versions.mix(SAMTOOLS_INDEX.out.versions.first())
        
        bqsr_bai = SAMTOOLS_INDEX.out.bai

    emit:
        bam      = bqsr_bam
        bai      = bqsr_bai
        versions = ch_versions

}
