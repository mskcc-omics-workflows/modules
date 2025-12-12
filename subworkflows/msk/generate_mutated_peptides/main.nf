include { MUTALYZER_RETRIEVER } from '../../../modules/msk/mutalyzer/retriever/main'
include { GENERATEMUTFASTA } from '../../../modules/msk/generatemutfasta/1.2/main'

workflow GENERATE_MUTATED_PEPTIDES {

    take:

    ch_maf         // channel: [ val(meta), maf ]
    ref_fasta
    gff3

    main:

    ch_versions = Channel.empty()

    ch_fasta_and_gff3 =  ref_fasta
                            .merge(gff3)
                            .map{
                                new Tuple([ id:"mutalyzer_retriever_"+file(it[0]).name +"_"+ file(it[1]).name], it[0], it[1])
                            }

    MUTALYZER_RETRIEVER( ch_fasta_and_gff3 )

    ch_versions = ch_versions.mix(MUTALYZER_RETRIEVER.out.versions)

    GENERATEMUTFASTA( ch_maf, MUTALYZER_RETRIEVER.out.mutalyzer_cache )

    ch_versions = ch_versions.mix(GENERATEMUTFASTA.out.versions)

    emit:

    mut_fasta      = GENERATEMUTFASTA.out.mut_fasta               // channel: [ val(meta), [ *.MUT_sequences.fa ] ]
    wt_fasta       = GENERATEMUTFASTA.out.wt_fasta                // channel: [ val(meta), [ *.WT_sequences.fa ] ]
    mut_fasta_log  = GENERATEMUTFASTA.out.mut_fasta_log           // channel: [ val(meta), [ *_generate_mut_fasta.log ] ]
    versions       = ch_versions                                  // channel: [ versions.yml ]
}
