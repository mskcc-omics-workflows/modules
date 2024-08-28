# Module: ppflagfixer

pplag-fixer for a single bam file

**Keywords:**

| Keywords |
|----------|
| ppflag |
| fixer |
| bams |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| htstools | Contains tools to process bam files for downstream copy number analysis. | None | https://github.com/mskcc/htstools |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample_name ]`  |  |
| process_bam | file | Sorted BAM/CRAM/SAM file | *.{bam,cram,sam} |
| process_bam_index | file | Index of the process bam file | *.bai |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample_name ]`  |  |
| versions | file | File containing software versions | versions.yml |
| ppflag_bam | file | Sorted BAM/CRAM/SAM file | *.{bam,cram,sam} |

## Authors

@huyu335

## Maintainers

@huyu335

