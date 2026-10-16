include { MUTALYZER_RETRIEVER } from '../../../modules/msk/mutalyzer/retriever/main'
include { GENERATEMUTFASTA }    from '../../../modules/msk/generatemutfasta/main'
include { NEOSV }               from '../../../modules/msk/neosv/main'
include { NEOANTIGENUTILS_GENERATEHLASTRING } from '../../../modules/msk/neoantigenutils/generatehlastring/main'

workflow GENERATE_MUTATED_PEPTIDES {

    take:

    ch_maf_hla_sv         // channel: [ val(meta), maf, hla, sv ]
    ref_fasta
    gff3
    gtf
    cdna

    main:

    ch_versions = channel.empty()

    ch_maf = ch_maf_hla_sv
                .map{
                    [it[0],it[1]]
                }

    ch_hla = ch_maf_hla_sv
                .map{
                    [it[0],it[2]]
                }

    ch_sv = ch_maf_hla_sv
                .map{
                    [it[0],it[3]]
                }

    ch_fasta_and_gff3 =  ref_fasta
                            .merge(gff3)
                            .map{
                                [[ id:"mutalyzer_retriever_"+file(it[0]).name +"_"+ file(it[1]).name], it[0], it[1]]
                            }

    ch_gtf_and_cdna = gtf
                            .merge(cdna)
                            .map{
                                [it[0], it[1]]
                            }

    NEOANTIGENUTILS_GENERATEHLASTRING( ch_hla )

    ch_versions = ch_versions.mix(NEOANTIGENUTILS_GENERATEHLASTRING.out.versions)

    MUTALYZER_RETRIEVER( ch_fasta_and_gff3 )

    ch_versions = ch_versions.mix(MUTALYZER_RETRIEVER.out.versions)

    GENERATEMUTFASTA( ch_maf, MUTALYZER_RETRIEVER.out.mutalyzer_cache.collect() )

    ch_versions = ch_versions.mix(GENERATEMUTFASTA.out.versions)

    ch_neosv_branched = branchNEOSVInput( ch_sv , NEOANTIGENUTILS_GENERATEHLASTRING.out.hlastring )

    NEOSV( ch_neosv_branched.with_sv, ch_gtf_and_cdna )

    ch_versions = ch_versions.mix(NEOSV.out.versions)

    // Pad SV outputs with empty placeholders for samples without SV input so that
    // downstream per-sample joins never have to wait for the full channel to close.
    ch_sv_mut_fasta = NEOSV.out.mutOut.mix( ch_neosv_branched.without_sv.map{ [it[0], []] } )
    ch_sv_wt_fasta  = NEOSV.out.wtOut.mix( ch_neosv_branched.without_sv.map{ [it[0], []] } )

    emit:

    mut_fasta      = GENERATEMUTFASTA.out.mut_fasta                   // channel: [ val(meta), [ *.MUT_sequences.fa ] ]
    wt_fasta       = GENERATEMUTFASTA.out.wt_fasta                    // channel: [ val(meta), [ *.WT_sequences.fa ] ]
    mut_fasta_log  = GENERATEMUTFASTA.out.mut_fasta_log               // channel: [ val(meta), [ *_generate_mut_fasta.log ] ]
    sv_mut_fasta   = ch_sv_mut_fasta                                  // channel: [ val(meta), [ *.SV.MUT.fa ] | [] ]
    sv_wt_fasta    = ch_sv_wt_fasta                                   // channel: [ val(meta), [ *.SV.WT.fa ]  | [] ]
    hla_string     = NEOANTIGENUTILS_GENERATEHLASTRING.out.hlastring  // channel: [ val(meta), [ hla_string ] ]
    versions       = ch_versions                                      // channel: [ versions.yml ]
}

def branchNEOSVInput(sv_bedpe, hla_str) {
        def sv_bedpe_channel = sv_bedpe
            .map{
                [it[0],it]
                }

        def hla_str_channel = hla_str
            .map{
                [it[0],it]
                }

        def merged_sv_hla = sv_bedpe_channel
            .join(hla_str_channel, by:0)
            .map{
                [it[1][0], it[1][1], it[2][1]]
            }
            .branch{
                with_sv:    it[1] != null && it[2] != null
                without_sv: true
            }
        return merged_sv_hla
}
