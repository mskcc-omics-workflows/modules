# Module: phylowgs_multievolve

Create trees from input from phylowgs_createinput

**Keywords:**

| Keywords |
|----------|
| phylowgs |
| CNVs |
| FACETs |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| phylowgs_multievolve | Program to create trees from input from phylowgs_createinput | None | https://genomebiology.biomedcentral.com/articles/10.1186/s13059-015-0602-8 |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| cnv_data | file | copy number input data from phylowgs_createinput | *.{txt} |
| ssm_data | file | mutation input data from phylowgs_createinput | *.{txt} |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| trees | file | Zip file containing the completed trees | trees.zip |
| versions | file | File containing software versions | versions.yml |

## Authors

@nikhil

## Maintainers

@nikhil

