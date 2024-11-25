include { NEOANTIGENUTILS_GENERATEHLASTRING  } from '../../../modules/msk/neoantigenutils/generatehlastring/main'
include { NEOANTIGENUTILS_GENERATEMUTFASTA  } from '../../../modules/msk/neoantigenutils/generatemutfasta/main'
include { NETMHCPAN4 } from '../../../modules/msk/netmhcpan4/main'
include { NETMHC3 } from '../../../modules/msk/netmhc3/main'
include { NETMHCSTABPAN } from '../../../modules/msk/netmhcstabpan/main'
include { NEOANTIGENUTILS_FORMATNETMHCPAN } from '../../../modules/msk/neoantigenutils/formatnetmhcpan/main'

workflow NETMHCSTABANDPAN {

    take:

    ch_maf_and_hla         // channel: [ val(meta), maf, hla ]
    ch_cds_and_cdna        // channel: [ cfs, cdna]
    ch_neosv_out

    main:

    ch_versions = Channel.empty()

    ch_hla = ch_maf_and_hla
                .map{
                    new Tuple(it[0],it[2])
                }


    ch_maf = ch_maf_and_hla
                .map{
                    new Tuple(it[0],it[1])
                }


    NEOANTIGENUTILS_GENERATEHLASTRING( ch_hla )


    ch_versions = ch_versions.mix(NEOANTIGENUTILS_GENERATEHLASTRING.out.versions)

    NEOANTIGENUTILS_GENERATEMUTFASTA( ch_maf, ch_cds_and_cdna )

    ch_versions = ch_versions.mix(NEOANTIGENUTILS_GENERATEMUTFASTA.out.versions)

    ch_netmhcinput = createNETMHCInput(NEOANTIGENUTILS_GENERATEMUTFASTA.out.wt_fasta,
                                        NEOANTIGENUTILS_GENERATEMUTFASTA.out.mut_fasta,
                                        NEOANTIGENUTILS_GENERATEHLASTRING.out.hlastring,
                                        ch_neosv_out
                                        )
    
    NETMHCSTABPAN( ch_netmhcinput )

    ch_versions = ch_versions.mix(NETMHCSTABPAN.out.versions)

    merged_pan_and_stab = Channel.empty()

    if ( params.netmhc3 ) {
        
        NETMHC3( ch_netmhcinput )
        ch_versions = ch_versions.mix(NETMHC3.out.versions)
        merged_pan_and_stab = NETMHC3.out.netmhcoutput.mix(NETMHCSTABPAN.out.netmhcstabpanoutput)
    }
    else{

        NETMHCPAN4( ch_netmhcinput )
        ch_versions = ch_versions.mix(NETMHCPAN4.out.versions)
        merged_pan_and_stab = NETMHCPAN4.out.netmhcpanoutput.mix(NETMHCSTABPAN.out.netmhcstabpanoutput)
    }    

    NEOANTIGENUTILS_FORMATNETMHCPAN( merged_pan_and_stab )

    ch_versions = ch_versions.mix( NEOANTIGENUTILS_FORMATNETMHCPAN.out.versions )

    emit:

    tsv        = NEOANTIGENUTILS_FORMATNETMHCPAN.out.netMHCpanreformatted     // channel: [ val(meta), [ tsv ] ]
    //xls        = NETMHCPAN.out.xls                                            // channel: [ val(meta), [ xls ] ]
    mut_fasta  = NEOANTIGENUTILS_GENERATEMUTFASTA.out.mut_fasta               // channel: [ val(meta), [ *.MUT_sequences.fa ] ]
    wt_fasta   = NEOANTIGENUTILS_GENERATEMUTFASTA.out.wt_fasta                // channel: [ val(meta), [ *.WT_sequences.fa ] ]
    versions   = ch_versions                                                  // channel: [ versions.yml ]
}

def createNETMHCInput(wt_fasta, mut_fasta, hla, sv_fastas) {
        mut_fasta_channel = mut_fasta
            .map{
                new Tuple(it[0],it)
                }

        wt_fasta_channel = wt_fasta
            .map{
                new Tuple(it[0],it)
                }

        mut_SVfasta_channel = sv_fastas
            .map{
                new Tuple(it[0],it[1])
                }

        wt_SVfasta_channel = sv_fastas
            .map{
                new Tuple(it[0],it[2])
                }

        hla_channel = hla
            .map{
                new Tuple(it[0],it[1])
                }

        merged_mut_fasta = mut_fasta_channel
            .join(mut_SVfasta_channel, by:0)

        merged_mut = merged_mut_fasta.join(hla_channel)
            .map{
                new Tuple(it[1][0], it[1][1], it[2], it[3],"MUT")
            }

        merged_wt_fasta = wt_fasta_channel
            .join(wt_SVfasta_channel,by: 0)

        merged_wt = merged_mut_fasta
            .join(hla_channel)
            .map{
                new Tuple(it[1][0], it[1][1], it[2], it[3],"WT")
            }
        merged = merged_mut.mix(merged_wt)
        return merged
}
