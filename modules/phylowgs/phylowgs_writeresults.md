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

## Outputs

| Output | Suboutput | Type | Description | Pattern |
|--------|-----------|------|-------------|---------|
| summ | meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| summ | *.summ.json.gz | file | Output file for JSON-formatted tree summaries | *.summ.json.gz |
| muts | meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| muts | *.muts.json.gz | file | Output file for JSON-formatted list of mutations | *.muts.json.gz |
| mutass | meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| mutass | *.mutass.zip | file | Output file for JSON-formatted list of SSMs and CNVs | *.mutass.zip |
| versions | versions.yml | file | File containing software versions | versions.yml |

## Authors

@nikhil

## Maintainers

@nikhil

