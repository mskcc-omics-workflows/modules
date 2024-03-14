# Module: gbcms

This module wraps GetBaseCountsMultiSample, which calculates the base counts in multiple BAM files for all the sites in a given VCF file or MAF file

**Keywords:**

| Keywords |
|----------|
| basecount |
| bams |
| vcf |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| gbcms | Calculate the base counts in multiple BAM files for all the sites in a given VCF file or MAF file | None | https://github.com/msk-access/GetBaseCountsMultiSample |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:test, single_end:false ]`  |  |
| fasta | file | Input reference sequence file | *.fasta |
| fastafai | file | Index of the reference Fasta | *.fai |
| bam | file | Input bam file, in the format of SAMPLE_NAME:BAM_FILE. This paramter need to be specified at least once | *.bam |
| bambai | file | Index of Bam | *.bai |
| variant_file | file | Input variant file in TCGA maf format. --maf or --vcf need to be specified at least once. But --maf and --vcf are mutually exclusive | *.{maf,vcf} |
| output | string | Output file |  |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:test, single_end:false ]`  |  |
| versions | file | File containing software versions | versions.yml |
| variant_file | file | base counts in multiple BAM files for all the sites in a given VCF file or MAF file | *.{vcf,maf} |

## Authors

@buehlere

## Maintainers

None

