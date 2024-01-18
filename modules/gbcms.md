``` ---
# yaml-language-server: =https://raw.githubusercontent.com/nf-core/modules/master/modules/yaml-schema.json
name: gbcms
description: This module wraps GetBaseCountsMultiSample, which calculates the base counts in multiple BAM files for all the sites in a given VCF file or MAF file
keywords:
  - basecount
  - bams
  - vcf
tools:
  - gbcms:
      description: Calculate the base counts in multiple BAM files for all the sites in a given VCF file or MAF file
      homepage: https://github.com/msk-access/GetBaseCountsMultiSample
      documentation: https://github.com/msk-access/GetBaseCountsMultiSample/blob/master/README.md

input:
  # Only when we have meta
  - meta:
      type: map
      description: |
        Groovy Map containing sample information
        e.g. 

  - fasta:
      type: file
      description: Input reference sequence file
      pattern: *.fasta

  - fastafai:
      type: file
      description: Index of the reference Fasta
      pattern: *.fai
  - bam:
      type: file
      description: Input bam file, in the format of SAMPLE_NAME:BAM_FILE. This paramter need to be specified at least once
      pattern: *.bam
  - bambai:
      type: file
      description: Index of Bam
      pattern: *.bai
  - variant_file:
      type: file
      description: Input variant file in TCGA maf format. --maf or --vcf need to be specified at least once. But --maf and --vcf are mutually exclusive
      pattern: *.maf
  - output:
      type: string
      description: Output file

output:
  - versions:
      type: file
      description: File containing software versions
      pattern: versions.yml
  - variant_file:
      type: file
      description: base counts in multiple BAM files for all the sites in a given VCF file or MAF file
      pattern: *.vcf

authors:
  - @buehlere
 ``` file
      homepage: https://github.com/msk-access/GetBaseCountsMultiSample
      documentation: https://github.com/msk-access/GetBaseCountsMultiSample/blob/master/README.md

input:
  # Only when we have meta
  - meta:
      type: map
      description: |
        Groovy Map containing sample information
        e.g. 

  - fasta:
      type: file
      description: Input reference sequence file
      pattern: *.fasta

  - fastafai:
      type: file
      description: Index of the reference Fasta
      pattern: *.fai
  - bam:
      type: file
      description: Input bam file, in the format of SAMPLE_NAME:BAM_FILE. This paramter need to be specified at least once
      pattern: *.bam
  - bambai:
      type: file
      description: Index of Bam
      pattern: *.bai
  - variant_file:
      type: file
      description: Input variant file in TCGA maf format. --maf or --vcf need to be specified at least once. But --maf and --vcf are mutually exclusive
      pattern: *.maf
  - output:
      type: string
      description: Output file

output:
  - versions:
      type: file
      description: File containing software versions
      pattern: versions.yml
  - variant_file:
      type: file
      description: base counts in multiple BAM files for all the sites in a given VCF file or MAF file
      pattern: *.maf

authors:
  - @buehlere
 ``` file
      homepage: https://github.com/msk-access/GetBaseCountsMultiSample
      documentation: https://github.com/msk-access/GetBaseCountsMultiSample/blob/master/README.md

input:
  # Only when we have meta
  - meta:
      type: map
      description: |
        Groovy Map containing sample information
        e.g. 

  - fasta:
      type: file
      description: Input reference sequence file
      pattern: *.fasta

  - fastafai:
      type: file
      description: Index of the reference Fasta
      pattern: *.fai
  - bam:
      type: file
      description: Input bam file, in the format of SAMPLE_NAME:BAM_FILE. This paramter need to be specified at least once
      pattern: *.bam
  - bambai:
      type: file
      description: Index of Bam
      pattern: *.bai
  - variant_file:
      type: file
      description: Input variant file in TCGA maf format. --maf or --vcf need to be specified at least once. But --maf and --vcf are mutually exclusive
      pattern: *.vcf
  - output:
      type: string
      description: Output file

output:
  - versions:
      type: file
      description: File containing software versions
      pattern: versions.yml
  - variant_file:
      type: file
      description: base counts in multiple BAM files for all the sites in a given VCF file or MAF file
      pattern: *.vcf

authors:
  - @buehlere
 ``` file
      homepage: https://github.com/msk-access/GetBaseCountsMultiSample
      documentation: https://github.com/msk-access/GetBaseCountsMultiSample/blob/master/README.md

input:
  # Only when we have meta
  - meta:
      type: map
      description: |
        Groovy Map containing sample information
        e.g. 

  - fasta:
      type: file
      description: Input reference sequence file
      pattern: *.fasta

  - fastafai:
      type: file
      description: Index of the reference Fasta
      pattern: *.fai
  - bam:
      type: file
      description: Input bam file, in the format of SAMPLE_NAME:BAM_FILE. This paramter need to be specified at least once
      pattern: *.bam
  - bambai:
      type: file
      description: Index of Bam
      pattern: *.bai
  - variant_file:
      type: file
      description: Input variant file in TCGA maf format. --maf or --vcf need to be specified at least once. But --maf and --vcf are mutually exclusive
      pattern: *.vcf
  - output:
      type: string
      description: Output file

output:
  - versions:
      type: file
      description: File containing software versions
      pattern: versions.yml
  - variant_file:
      type: file
      description: base counts in multiple BAM files for all the sites in a given VCF file or MAF file
      pattern: *.maf

authors:
  - @buehlere
 ```
