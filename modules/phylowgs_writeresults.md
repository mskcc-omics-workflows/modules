# Module: phylowgs_writeresults

Write results from trees from phylowgs_multievolve

**Keywords:**

| Keywords |
|----------|
| phylowgs |
| CNVs |
| FACETs |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| phylowgs_writeresults | Write results from trees from phylowgs_multievolve | None | https://genomebiology.biomedcentral.com/articles/10.1186/s13059-015-0602-8 |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| trees | file | zip folder containing tree data from multievolve | *.zip |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| summ | file | Output file for JSON-formatted tree summaries | *.summ.json.gz |
| muts | file | Output file for JSON-formatted list of mutations | *.muts.json.gz |
| mutass | file | Output file for JSON-formatted list of SSMs and CNVs | *.mutass.zip |
| versions | file | File containing software versions | versions.yml |

## Authors

@nikhil

## Maintainers

@nikhil

