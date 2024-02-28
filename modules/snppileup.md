# Module: snppileup

Calculate snp pileups from a bam pair

**Keywords:**

| Keywords |
|----------|
| snp |
| pileup |
| bams |
| dbsnp |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| htstools | Contains tools to process bam files for downstream copy number analysis. | None | https://github.com/mskcc/htstools |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:pair_id ]`  |  |
| meta1 | map | Groovy Map containing sample information e.g. `[ id:pair_id ]`  |  |
| normal | file | Normal bam file | *.bam |
| normal_index | file | Index of the normal bam file | *.bai |
| tumor | file | Tumor bam file | *.bam |
| tumor_index | file | Index of tumor bam file | *.bai |
| dbsnp | file | The NCBI provided database vcf file on genetic variation | *.vcf.gz |
| dbsnp_index | file | The index of the dbsnp vcf file | *.vcf.gz.tbi |
| additional_bams | list | List of additional bams to include |  |
| additional_bam_index | list | List of additional bam indexes to include |  |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| pileup | file | The pileup file | *.snp_pileup.gz |
| versions | file | File containing software versions | versions.yml |

## Authors

@nikhil

## Maintainers

@nikhil

