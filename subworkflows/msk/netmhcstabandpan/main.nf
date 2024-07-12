include { NEOANTIGENUTILS_GENERATEHLASTRING  } from '../../../modules/msk/neoantigenutils/generatehlastring/main'
include { NEOANTIGENUTILS_GENERATEMUTFASTA  } from '../../../modules/msk/neoantigenutils/generatemutfasta/main'
include { NETMHCPAN } from '../../../modules/msk/netmhcpan/main'
include { NETMHCSTABPAN } from '../../../modules/msk/netmhcstabpan/main'
include { NEOANTIGENUTILS_FORMATNETMHCPAN } from '../../../modules/msk/neoantigenutils/formatnetmhcpan/main'

workflow NETMHCSTABANDPAN {

    take:

    ch_maf_and_hla         // channel: [ val(meta), maf, hla ]
    ch_cds_and_cdna        // channel: [ cfs, cdna]

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
                                        NEOANTIGENUTILS_GENERATEHLASTRING.out.hlastring
                                        )


    NETMHCPAN( ch_netmhcinput )

    ch_versions = ch_versions.mix(NETMHCPAN.out.versions)

    NETMHCSTABPAN( ch_netmhcinput )

    ch_versions = ch_versions.mix(NETMHCSTABPAN.out.versions)

    merged_pan_and_stab = NETMHCPAN.out.netmhcpanoutput.mix(NETMHCSTABPAN.out.netmhcstabpanoutput)

    NEOANTIGENUTILS_FORMATNETMHCPAN( merged_pan_and_stab )

    ch_versions = ch_versions.mix( NEOANTIGENUTILS_FORMATNETMHCPAN.out.versions )



    emit:

    tsv        = NEOANTIGENUTILS_FORMATNETMHCPAN.out.netMHCpanreformatted     // channel: [ val(meta), [ tsv ] ]
    xls        = NETMHCPAN.out.xls                                            // channel: [ val(meta), [ xls ] ]
    mut_fasta  = NEOANTIGENUTILS_GENERATEMUTFASTA.out.mut_fasta               // channel: [ val(meta), [ *.MUT_sequences.fa ] ]
    wt_fasta   = NEOANTIGENUTILS_GENERATEMUTFASTA.out.wt_fasta                // channel: [ val(meta), [ *.WT_sequences.fa ] ]
    versions   = ch_versions                                                  // channel: [ versions.yml ]
}

def createNETMHCInput(wt_fasta, mut_fasta, hla) {
        mut_fasta_channel = mut_fasta
            .map{
                new Tuple(it[0].id,it)
                }
        wt_fasta_channel = wt_fasta
            .map{
                new Tuple(it[0].id,it)
                }
        hla_channel = hla
            .map{
                new Tuple(it[0].id,it)
                }
        merged_mut = mut_fasta_channel
            .join(hla_channel)
            .map{
                new Tuple(it[1][0], it[1][1],it[2][1],"MUT")
            }
        merged_wt = wt_fasta_channel
            .join(hla_channel)
            .map{
                new Tuple(it[1][0], it[1][1],it[2][1],"WT")
            }
        merged = merged_mut.mix(merged_wt)
        
        return merged
}
