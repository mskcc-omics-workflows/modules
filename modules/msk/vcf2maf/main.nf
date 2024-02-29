
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
    def args2 = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
   
    """
    vcf2maf.pl $args \\
    --normal-id ${meta.control_id} \\
    $args2 --tumor-id \\
    ${meta.case_id} \\
    --vcf-normal-id ${meta.control_id} \\
    --vcf-tumor-id ${meta.case_id} \\
    --input-vcf ${vcf} \\
    --output-maf ${prefix}.maf \\
    --ref-fasta ${ref_fasta} \\
    --vep-path /usr/local/bin


    cat <<-END_VERSIONS > versions.yml
    "${task.process}": 
        vcf2maf: \$(echo \$(vcf2maf.pl --help) | echo 'vcf2maf version 1.6.21 VEP v105')
    END_VERSIONS
    """
    
    stub:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    echo "stub test" >> ${prefix}.maf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}": 
        vcf2maf: \$(echo \$(vcf2maf.pl --help) | echo 'vcf2maf version 1.6.21 VEP v105')
    END_VERSIONS
    """
}


//standard VCF2MAF args arguments: --buffer-size 5000 --maf-center mskcc.org --min-hom-vaf 0.7 --ncbi-build GRCh37 
//standard VCF2MAF args2 arguments: --retain-info set,TYPE,FAILURE_REASON,MUTECT 