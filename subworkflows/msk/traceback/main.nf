// TODO nf-core: If in doubt look at other nf-core/subworkflows to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/subworkflows
//               You can also ask for help via your pull request or on the #subworkflows channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core: A subworkflow SHOULD import at least two modules

include { SAMTOOLS_SORT      } from '../../../modules/nf-core/samtools/sort/main'
include { SAMTOOLS_INDEX     } from '../../../modules/nf-core/samtools/index/main'

workflow TRACEBACK {

    take:
    // TODO nf-core: edit input (take) channels
    sample_files // channel: [ val(meta), [ bam ] ]

    main:

    ch_versions = Channel.empty()

    // [ [sample: 'sample', patient: 'patient'],maf,bam, bam_xs ]
    // .collect(sample_files)
    // tuple("patient":row.patient_id, "id":row.sample_id, file(row.standard_bam), file(row.standard_bam + '.bai'),[],[],[],[])
    // .map {row -> tuple("patient":row.patient_id, file(row.maf))}
    // .groupTuple(by:0) // group by patient if provided
    // .set{maf_list}
    // reference

    // Concat Input Mafs, per patient if provided
    PVMAFCONCAT_INITIAL(maf_list, params.header)
    ch_versions = ch_versions.mix(PVMAFCONCAT_INITIAL.out.versions.first())

    // genotype --all, make container and module
    GENOTYPEVARIANTS_ALL_ST(s_bam_list_maf, params.reference, file(params.reference + '.fai'))
    ch_versions = ch_versions.mix(GENOTYPEVARIANTS_ALL_ST.out.versions.first())
    GENOTYPEVARIANTS_ALL_LQ(lq_bam_list_maf, params.reference, file(params.reference + '.fai'))
    ch_versions = ch_versions.mix(GENOTYPEVARIANTS_ALL_LQ.out.versions.first())
    // Grab Relevant Maf Output from GENOTYPEVARIANTS_ALL_(ST|LQ)
    GENOTYPEVARIANTS_ALL_ST.out.maf
    .transpose()
    .branch {
        genotyped: it[1] =~ /.*ORG-STD_genotyped.maf/
        }
    .set{split_genotype_st}

    GENOTYPEVARIANTS_ALL_LQ.out.maf
    .transpose()
    .branch {
        genotyped: it[1] =~ /.*ORG-SIMPLEX-DUPLEX_genotyped.maf/
        }
    .set{split_genotype_lq}

    // Combine GENOTYPEVARIANTS_ALL_(ST|LQ) Mafs and Group by Patient
    split_genotype_st
    .concat(split_genotype_lq.genotyped)
    .map{meta, files -> tuple('patient': meta['patient'], files )}
    .groupTuple()
    .set{all_genotype}

    // Concat Input Mafs, per patient if provided
    // These combine the two stats from standard and access.
    // pv maf traceback combine
    PVMAFCONCAT_GENOTYPE(all_genotype, params.genotype_header)
    ch_versions = ch_versions.mix(PVMAFCONCAT_GENOTYPE.out.versions.first())
    // Tag with Traceback Columns
    PVMAF_TAG(PVMAFCONCAT_GENOTYPE.out.maf, 'traceback')
    ch_versions = ch_versions.mix(PVMAF_TAG.out.versions.first())

    emit:
    // TODO nf-core: edit emitted channels
    bam      = SAMTOOLS_SORT.out.bam           // channel: [ val(meta), [ bam ] ]
    bai      = SAMTOOLS_INDEX.out.bai          // channel: [ val(meta), [ bai ] ]
    csi      = SAMTOOLS_INDEX.out.csi          // channel: [ val(meta), [ csi ] ]

    versions = ch_versions                     // channel: [ versions.yml ]
}

