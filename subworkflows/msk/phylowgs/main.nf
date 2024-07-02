include { PHYLOWGS_CREATEINPUT } from '../../../modules/msk/phylowgs/createinput/main'
include { PHYLOWGS_PARSECNVS } from '../../../modules/msk/phylowgs/parsecnvs/main'
include { PHYLOWGS_MULTIEVOLVE } from '../../../modules/msk/phylowgs/multievolve/main'
include { PHYLOWGS_WRITERESULTS } from '../../../modules/msk/phylowgs/writeresults/main'

workflow PHYLOWGS {

    take:
    ch_input_maf_and_genelevel

    main:

    ch_versions = Channel.empty()

    ch_genelevel = ch_input_maf_and_genelevel
                        .map{
                            new Tuple(it[0],it[2])
                        }

    ch_maf = ch_input_maf_and_genelevel
                        .map{
                            new Tuple(it[0],it[1])
                        }

    PHYLOWGS_PARSECNVS(ch_genelevel)

    ch_versions = ch_versions.mix(PHYLOWGS_PARSECNVS.out.versions)

    ch_maf_and_cnv = join_maf_with_cnv(ch_maf,PHYLOWGS_PARSECNVS.out.cnv)

    PHYLOWGS_CREATEINPUT(ch_maf_and_cnv)

    ch_versions = ch_versions.mix(PHYLOWGS_CREATEINPUT.out.versions)

    PHYLOWGS_MULTIEVOLVE(PHYLOWGS_CREATEINPUT.out.phylowgsinput)

    ch_versions = ch_versions.mix(PHYLOWGS_MULTIEVOLVE.out.versions)

    PHYLOWGS_WRITERESULTS(PHYLOWGS_MULTIEVOLVE.out.trees)

    ch_versions = ch_versions.mix(PHYLOWGS_WRITERESULTS.out.versions)


    emit:

    summ        = PHYLOWGS_WRITERESULTS.out.summ        // channel: [ val(meta), [ summ ] ]
    muts        = PHYLOWGS_WRITERESULTS.out.muts        // channel: [ val(meta), [ muts ] ]
    mutass      = PHYLOWGS_WRITERESULTS.out.mutass      // channel: [ val(meta), [ mutass ] ]
    versions    = ch_versions                           // channel: [ versions.yml ]
}

def join_maf_with_cnv(maf,cnv) {
        maf_channel = maf
            .map{
                new Tuple(it[0].id,it)
                }
        cnv_channel = cnv
            .map{
                new Tuple(it[0].id,it)
                }
        mergedWithKey = maf_channel
            .join(cnv_channel)
        merged = mergedWithKey
            .map{
                new Tuple(it[1][0],it[1][1],it[2][1])
            }
        return merged

}
