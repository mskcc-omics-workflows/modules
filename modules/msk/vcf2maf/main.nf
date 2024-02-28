
process VCF2MAF {
    tag "$meta.id"
    label 'process_low' 

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'ghcr.io/msk-access/vcf2maf:1.6.21-vep105':
        'ghcr.io/msk-access/vcf2maf:1.6.21-vep105' }"

    input:

    tuple val(meta), path(vcf), path(ref_fasta)
    
    output:
    
    tuple val(meta), path("*.maf"), emit: maf


    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    
    def prefix = task.ext.prefix ?: "${meta.id}"
   
    """
    vcf2maf.pl --input-vcf ${vcf} --output-maf ${prefix}.maf --ref-fasta ${ref_fasta} --vep-path /usr/local/bin
    """
    
    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    vcf2maf.pl --buffer-size 5000 --maf-center mskcc.org --min-hom-vaf 0.7 --ncbi-build GRCh37 --normal-id ${meta.control_id} --retain-info set,TYPE,FAILURE_REASON,MUTECT --tumor-id ${meta.case_id} --vcf-normal-id ${meta.control_id} --vcf-tumor-id ${meta.case_id}  --input-vcf ${vcf} --output-maf ${prefix}.maf --ref-fasta ${ref_fasta} --vep-path /usr/local/bin
    """
}

// --input-vcf      Path to input file in VCF format
//      --output-maf     Path to output MAF file
//      --tmp-dir        Folder to retain intermediate VCFs after runtime [Default: Folder containing input VCF]
//      --tumor-id       Tumor_Sample_Barcode to report in the MAF [TUMOR]
//      --normal-id      Matched_Norm_Sample_Barcode to report in the MAF [NORMAL]
//      --vcf-tumor-id   Tumor sample ID used in VCF's genotype columns [--tumor-id]
//      --vcf-normal-id  Matched normal ID used in VCF's genotype columns [--normal-id]
//      --custom-enst    List of custom ENST IDs that override canonical selection
//      --vep-path       Folder containing the vep script [~/miniconda3/bin]
//      --vep-data       VEP's base cache/plugin directory [~/.vep]
//      --vep-forks      Number of forked processes to use when running VEP [4]
//      --vep-custom     String to pass into VEP's --custom option []
//      --vep-config     Config file to pass into VEP's --config option []
//      --vep-overwrite  Allow VEP to overwrite output VCF if it exists
//      --buffer-size    Number of variants VEP loads at a time; Reduce this for low memory systems [5000]
//      --any-allele     When reporting co-located variants, allow mismatched variant alleles too
//      --inhibit-vep    Skip running VEP, but extract VEP annotation in VCF if found
//      --online         Use useastdb.ensembl.org instead of local cache (supports only GRCh38 VCFs listing <100 events)
//      --ref-fasta      Reference FASTA file [~/.vep/homo_sapiens/102_GRCh37/Homo_sapiens.GRCh37.dna.toplevel.fa.gz]
//      --max-subpop-af  Add FILTER tag common_variant if gnomAD reports any subpopulation AFs greater than this [0.0004]
//      --species        Ensembl-friendly name of species (e.g. mus_musculus for mouse) [homo_sapiens]
//      --ncbi-build     NCBI reference assembly of variants MAF (e.g. GRCm38 for mouse) [GRCh37]
//      --cache-version  Version of offline cache to use with VEP (e.g. 75, 91, 102) [Default: Installed version]
//      --maf-center     Variant calling center to report in MAF [.]
//      --retain-info    Comma-delimited names of INFO fields to retain as extra columns in MAF []
//      --retain-fmt     Comma-delimited names of FORMAT fields to retain as extra columns in MAF []
//      --retain-ann     Comma-delimited names of annotations (within the VEP CSQ/ANN) to retain as extra columns in MAF []
//      --min-hom-vaf    If GT undefined in VCF, minimum allele fraction to call a variant homozygous [0.7]
//      --remap-chain    Chain file to remap variants to a different assembly before running VEP
//      --verbose        Print more things to log progress
//      --help           Print a brief help message and quit
//      --man            Print the detailed manual
