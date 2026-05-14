include { NETMHCPAN4 } from '../../../modules/msk/netmhcpan4/main'
include { NETMHC3 } from '../../../modules/msk/netmhc3/main'
include { NETMHCSTABPAN } from '../../../modules/msk/netmhcstabpan/main'
include { NEOANTIGENUTILS_FORMATNETMHCPAN } from '../../../modules/msk/neoantigenutils/formatnetmhcpan/main'

workflow NETMHCSTABANDPAN {

    take:

    ch_fasta_and_hla         // channel: [ val(meta), mut_fasta, wt_fasta, hla(str) ]
    ch_sv_fasta              // channel: [ val(meta), sv_mut_fasta, sv_wt_fasta ]

    main:

    ch_versions = channel.empty()

    ch_netmhcinput = createNETMHCInput(ch_fasta_and_hla, ch_sv_fasta)

    NETMHCSTABPAN( ch_netmhcinput )

    ch_versions = ch_versions.mix(NETMHCSTABPAN.out.versions)

    merged_pan_and_stab = channel.empty()

    merged_pan_and_stab = merged_pan_and_stab.mix( NETMHCSTABPAN.out.netmhcstabpanoutput )

    if ( params.netmhc3 ) {

        NETMHC3( ch_netmhcinput )
        ch_versions = ch_versions.mix(NETMHC3.out.versions)
        merged_pan_and_stab = merged_pan_and_stab.mix(NETMHC3.out.netmhcoutput)
    }
    else{

        NETMHCPAN4( ch_netmhcinput )
        ch_versions = ch_versions.mix(NETMHCPAN4.out.versions)
        merged_pan_and_stab = merged_pan_and_stab.mix(NETMHCPAN4.out.netmhcpanoutput)
    }

    NEOANTIGENUTILS_FORMATNETMHCPAN( merged_pan_and_stab )

    ch_versions = ch_versions.mix( NEOANTIGENUTILS_FORMATNETMHCPAN.out.versions )

    emit:

    tsv        = NEOANTIGENUTILS_FORMATNETMHCPAN.out.netMHCpanreformatted     // channel: [ val(meta), [ tsv ] ]
    versions   = ch_versions                                                  // channel: [ versions.yml ]
}

def createNETMHCInput(fastas_and_hla, sv_fastas) {
        def fastas_and_hla_channel = fastas_and_hla
            .map{
                [it[0],it]
                }

        def sv_fastas_channel = sv_fastas
            .map{
                [it[0],it]
                }

        // remainder: true keeps samples that have no SV data (sv_fastas is empty when no SVs provided)
        def merged_mut = fastas_and_hla_channel
            .join(sv_fastas_channel, by:0, remainder: true)
            .map({
                def sv = it[2] ?: [null, [], []]
                [it[1][0], it[1][1], sv[1], it[1][3], "MUT"]
            })

        def merged_wt = fastas_and_hla_channel
            .join(sv_fastas_channel, by:0, remainder: true)
            .map({
                def sv = it[2] ?: [null, [], []]
                [it[1][0], it[1][2], sv[2], it[1][3], "WT"]
            })
        def merged = merged_mut.mix(merged_wt)
        return merged
}
