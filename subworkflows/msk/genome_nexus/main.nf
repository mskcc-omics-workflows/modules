include { GENOMENEXUS_VCF2MAF      } from '../../../modules/msk/genomenexus/vcf2maf/main'
include { GENOMENEXUS_ANNOTATIONPIPELINE     } from '../../../modules/msk/genomenexus/annotationpipeline/main'

workflow GENOME_NEXUS {

    take:
    ch_vcf // channel: [ val(meta), [ vcf ] ]

    main:

    ch_versions = Channel.empty()

    

    GENOMENEXUS_VCF2MAF ( ch_vcf )
    ch_versions = ch_versions.mix(GENOMENEXUS_VCF2MAF.out.versions.first())
    GENOMENEXUS_ANNOTATIONPIPELINE( GENOMENEXUS_VCF2MAF.out.maf )


    emit:
    
    maf      = GENOMENEXUS_VCF2MAF.out.maf           // channel: [ val(meta), [ maf ] ]
    versions = ch_versions                     // channel: [ versions.yml ]
}

