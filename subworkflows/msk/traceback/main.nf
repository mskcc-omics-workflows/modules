include { PVMAF_CONCAT as PVMAFCONCAT_INITIAL} from '../../../modules/msk/pvmaf/concat'
include { PVMAF_CONCAT as PVMAFCONCAT_GENOTYPE} from '../../../modules/msk/pvmaf/concat'
include { GENOTYPEVARIANTS_ALL as GENOTYPEVARIANTS_ALL} from '../../../modules/msk/genotypevariants/all'

workflow TRACEBACK {

    take:
    bams
    // [[patient:null, id:'sample'], standard.bam, standard.bam.bai, [], [], [], []]
    // or
    // [[patient:null, id:'sample'], [], [], duplex.bam, duplex.bam.bai, simplex.bam, simplex.bam.bai]
    mafs // [[patient:null], [maf1,...,maf2] ]
    reference // file(reference)
    reference_fai // file(reference.fai)

    main:

    // declare versions channel
    ch_versions = Channel.empty()

    // Concat Input Mafs
    PVMAFCONCAT_INITIAL(mafs)
    ch_versions = ch_versions.mix(PVMAFCONCAT_INITIAL.out.versions.first())

    // get bams and mafs, grouping by patient if provided
    PVMAFCONCAT_INITIAL.out.maf
    .map {it -> [it[0].subMap('patient')[0], *it[1..-1]] }
    .set{concat_maf}


    bams
    .map { it -> [it[0].subMap('patient')[0], it[0], *it[1..-1]] }
    .combine(concat_maf, by:0)
    .map { it[1..-1] }
    .set{bam_list_maf}
    // genotype each bam combined maf, per patient if provided
    GENOTYPEVARIANTS_ALL(bam_list_maf, reference, reference_fai)
    ch_versions = ch_versions.mix(GENOTYPEVARIANTS_ALL.out.versions.first())

    // For impact, grab ORG-STD Maf from GENOTYPEVARIANTS_ALL
    GENOTYPEVARIANTS_ALL.out.maf
    .transpose()
    .branch {
        genotyped: it[1] =~ /.*ORG-STD_genotyped.maf/
        }
    .set{split_genotype_imp}

    // For access, grab ORG-SIMPLEX-DUPLEX Maf from GENOTYPEVARIANTS_ALL
    GENOTYPEVARIANTS_ALL.out.maf
    .transpose()
    .branch {
        genotyped: it[1] =~ /.*ORG-SIMPLEX-DUPLEX_genotyped.maf/
        }
    .set{split_genotype_xs}



    // Combine impact and access mafs
    split_genotype_imp
    .concat(split_genotype_xs.genotyped)
    .map{meta, files -> tuple('patient': meta['patient'], files )}
    .groupTuple()
    .set{all_genotype}
    individual_genotype = all_genotype.collect()


    // concat gentoyped mafs, per patient if provided
    PVMAFCONCAT_GENOTYPE(all_genotype)
    ch_versions = ch_versions.mix(PVMAFCONCAT_GENOTYPE.out.versions.first())

    genotyped_maf = PVMAFCONCAT_GENOTYPE.out.maf


    emit:
    individual_genotyped_mafs = individual_genotype
    genotyped_maf = genotyped_maf                         // channel:[[patient:''], genotyped.maf]
    versions = ch_versions                     // channel: [ versions.yml ]
}
