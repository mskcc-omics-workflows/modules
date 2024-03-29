include { NEOANTIGENEDITING_ALIGNTOIEDB      } from '../../../modules/msk/neoantigenediting/aligntoIEDB'
include { NEOANTIGENEDITING_COMPUTEFITNESS   } from '../../../modules/msk/neoantigenediting/computeFitness'


workflow NEOANTIGEN_EDITING {

    take:
    neoantigenInput_ch
    iedbfasta

    main:

    ch_versions = Channel.empty()

    NEOANTIGENEDITING_ALIGNTOIEDB (neoantigenInput_ch, iedbfasta)
    ch_versions = ch_versions.mix(NEOANTIGENEDITING_ALIGNTOIEDB.out.versions.first())

    Channel.of(neoantigenInput_ch).set{ ch_input}
    ch_input.combine(NEOANTIGENEDITING_ALIGNTOIEDB.out.iedb_alignment, by: [0]).set{ ch_computeFitnessIn }

    ch_computeFitnessIn.view()

    NEOANTIGENEDITING_COMPUTEFITNESS ( ch_computeFitnessIn )

    ch_versions = ch_versions.mix(NEOANTIGENEDITING_COMPUTEFITNESS.out.versions.first())

    emit:
    annotated_output      = NEOANTIGENEDITING_COMPUTEFITNESS.out.annotated_output           // channel: [ val(meta), [ annotated_json ] ]
    versions = ch_versions                     // channel: [ versions.yml ]
}