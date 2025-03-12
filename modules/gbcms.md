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

## Outputs

| Output | Suboutput | Type | Description | Pattern |
|--------|-----------|------|-------------|---------|
| variant_file | meta | file | base counts in multiple BAM files for all the sites in a given VCF file or MAF file | *.{vcf,maf} |
| variant_file | *.{vcf,maf} | file | base counts in multiple BAM files for all the sites in a given VCF file or MAF file | *.{vcf,maf} |
| versions | versions.yml | file | File containing software versions | versions.yml |

## Authors

@buehlere

## Maintainers

None

