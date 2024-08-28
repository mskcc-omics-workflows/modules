# Module: phylowgs_parsecnvs

parse cnvs from FACETS for input to phylowgs

**Keywords:**

| Keywords |
|----------|
| phylowgs |
| CNVs |
| FACETs |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| phylowgs_parsecnvs | parser to convert FACETs output to phylowgs expected input | None | https://genomebiology.biomedcentral.com/articles/10.1186/s13059-015-0602-8 |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| facetsgenelevel | file | single sample facets gene level output | *.{txt} |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| cnv | file | converted cnv file for phylowgs upstream processing | *.txt |
| versions | file | File containing software versions | versions.yml |

## Authors

@pintoa1-mskcc

## Maintainers

@pintoa1-mskcc

