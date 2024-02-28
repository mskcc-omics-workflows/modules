// TODO nf-core: If in doubt look at other nf-core/subworkflows to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/subworkflows
//               You can also ask for help via your pull request or on the #subworkflows channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core: A subworkflow SHOULD import at least two modules
include { PVMAF_CONCAT as PVMAFCONCAT_INITIAL} from '../../../modules/msk/pvmaf/concat'
include { PVMAF_CONCAT as PVMAFCONCAT_GENOTYPE} from '../../../modules/msk/pvmaf/concat'
include { PVMAF_TAG                      } from '../../../modules/msk/pvmaf/tag'
include { GENOTYPEVARIANTS_ALL as GENOTYPEVARIANTS_ALL_ST} from '../../../modules/msk/genotypevariants/all'
include { GENOTYPEVARIANTS_ALL as GENOTYPEVARIANTS_ALL_LQ} from '../../../modules/msk/genotypevariants/all'

workflow TRACEBACK {

    take:
    // TODO nf-core: edit input (take) channels
    bams // channel: [ val(meta), bam, bam.bai ] or [ val(meta), [], [], _duplex.bam, _duplex.bam.bai, _simplex.bam, _simplex.bam.bai ]
    mafs // channel: [ val(meta), [maf] ]
    reference
    reference_fai

    main:

    ch_versions = Channel.empty()
    

    // [[patient:null, id:C-8LCJE9-M001-d], [], [], /Users/ebuehler/Downloads/traceback_test/test_data/C-8LCJE9-M001-d_cl_aln_srt_MD_IR_FX_BR__aln_srt_IR_FX-duplex.bam, /Users/ebuehler/Downloads/traceback_test/test_data/C-8LCJE9-M001-d_cl_aln_srt_MD_IR_FX_BR__aln_srt_IR_FX-duplex.bam.bai, /Users/ebuehler/Downloads/traceback_test/test_data/C-8LCJE9-M001-d_cl_aln_srt_MD_IR_FX_BR__aln_srt_IR_FX-simplex.bam, /Users/ebuehler/Downloads/traceback_test/test_data/C-8LCJE9-M001-d_cl_aln_srt_MD_IR_FX_BR__aln_srt_IR_FX-simplex.bam.bai]
    // [[patient:null, id:s_C_FWD2FT_X009_d], /Users/ebuehler/Downloads/traceback_test/test_data/s_C_FWD2FT_X009_d.rg.md.abra.printreads.bam, /Users/ebuehler/Downloads/traceback_test/test_data/s_C_FWD2FT_X009_d.rg.md.abra.printreads.bam.bai, [], [], [], []]
    // [[patient:null], [/Users/ebuehler/Downloads/traceback_test/test_data/s_C_FWD2FT_X009_d_data_mutations.txt, /Users/ebuehler/Downloads/traceback_test/test_data/s_C_FWD2FT_X009_d_data_mutations_copy.txt, /Users/ebuehler/Downloads/traceback_test/test_data/P-0038647-T04-IM6_data_mutations.txt, /Users/ebuehler/Downloads/traceback_test/test_data/C-8LCJE9-M001-d.DONOR22-TP.combined-variants.vep_keptrmv_taggedHotspots_fillout_filtered.maf]]
    // [ [sample: 'sample', patient: 'patient'],maf,bam, bam_xs ]
    // .collect(sample_files)
    // tuple("patient":row.patient_id, "id":row.sample_id, file(row.standard_bam), file(row.standard_bam + '.bai'),[],[],[],[])
    // .map {row -> tuple("patient":row.patient_id, file(row.maf))}
    // .groupTuple(by:0) // group by patient if provided
    // .set{maf_list}
    // reference
    // // Concat Input Mafs, per patient if provided
    PVMAFCONCAT_INITIAL(mafs)
    ch_versions = ch_versions.mix(PVMAFCONCAT_INITIAL.out.versions.first())

    // // genotype --all, make container and module
    bams
    .map { tuple( 'patient': it[0]['patient'], *it ) }
    .combine( PVMAFCONCAT_INITIAL.out.maf, by: 0 )
    .map { it[1..-1] }
    .set{s_bam_list_maf}

    GENOTYPEVARIANTS_ALL_ST(s_bam_list_maf, reference.collect(), reference_fai.collect())
    ch_versions = ch_versions.mix(GENOTYPEVARIANTS_ALL_ST.out.versions.first())
    // Grab Relevant Maf Output from GENOTYPEVARIANTS_ALL_(ST|LQ)
    // Grab Relevant Maf Output from GENOTYPEVARIANTS_ALL_(ST|LQ)
    GENOTYPEVARIANTS_ALL_ST.out.maf
    .transpose()
    .branch {
        genotyped: it[1] =~ /.*ORG-STD_genotyped.maf/
        }
    .set{split_genotype_st}

    GENOTYPEVARIANTS_ALL_ST.out.maf
    .transpose()
    .branch {
        genotyped: it[1] =~ /.*ORG-SIMPLEX-DUPLEX_genotyped.maf/
        }
    .set{split_genotype_lq}
    split_genotype_lq.view()
    // Combine GENOTYPEVARIANTS_ALL_(ST|LQ) Mafs and Group by Patient
    split_genotype_st
    .concat(split_genotype_lq.genotyped)
    .map{meta, files -> tuple('patient': meta['patient'], files )}
    .groupTuple()
    .set{all_genotype}
    // // Concat Input Mafs, per patient if provided
    // // These combine the two stats from standard and access.
    // // pv maf traceback combine
    PVMAFCONCAT_GENOTYPE(all_genotype)
    ch_versions = ch_versions.mix(PVMAFCONCAT_GENOTYPE.out.versions.first())
    // Tag with Traceback Columns
    PVMAF_TAG(PVMAFCONCAT_GENOTYPE.out.maf, 'traceback')
    ch_versions = ch_versions.mix(PVMAF_TAG.out.versions.first())
    PVMAF_TAG.out.maf.view()

    emit:
    maf = PVMAF_TAG.out.maf
    versions = ch_versions                     // channel: [ versions.yml ]
}

