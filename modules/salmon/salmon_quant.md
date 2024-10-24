# Module: salmon_quant

gene/transcript quantification with Salmon

**Keywords:**

| Keywords |
|----------|
| index |
| fasta |
| genome |
| reference |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| salmon | Salmon is a tool for wicked-fast transcript quantification from RNA-seq data  | GPL-3.0-or-later | https://salmon.readthedocs.io/en/latest/salmon.html |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. [ id:test, single_end:false ]  |  |
| reads | file | List of input FastQ files for single-end or paired-end data. Multiple single-end fastqs or pairs of paired-end fastqs are handled.  |  |
| index | file | The index file |  |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| results | directory | Folder containing the quantification results for a specific sample | ${prefix}.salmon.quant |
| quant | file | File containing the sample quantification results | ${meta.id}.quant.sf |
| versions | file | File containing software versions | versions.yml |

## Authors

@kevinmenden, @drpatelh

## Maintainers

@kevinmenden, @drpatelh

