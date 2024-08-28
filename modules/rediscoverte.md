# Module: rediscoverte

Quantify genome-wide TE expression in RNA sequencing data

**Keywords:**

| Keywords |
|----------|
| RNA |
| TE |
| expression |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| rediscoverte | a computational method for quantifying genome-wide TE expression in RNA sequencing data | GPL-3.0 | https://github.com/ucsffrancislab/REdiscoverTE |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| quant | list | quant file list |  |
| rmsk_annotation | file | rmsk annotation file | *.RDS |
| repName_repFamily_repClass_map | file | rep map file | *.tsv |
| genecode_annotation | file | genecode annotation file | *.RDS |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| rollup | directory | Directory containing results | REdiscoverTE_rollup |
| versions | file | File containing software versions | versions.yml |

## Authors

@nikhil

## Maintainers

@nikhil

