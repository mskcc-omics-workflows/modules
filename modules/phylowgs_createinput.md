# Module: phylowgs_createinput

Create input files for phylowgs

**Keywords:**

| Keywords |
|----------|
| phylowgs |
| cnvs |
| parser |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| phylowgs_createinput | create phylowgs expected input | None | https://genomebiology.biomedcentral.com/articles/10.1186/s13059-015-0602-8 |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |

## Outputs

| Output | Suboutput | Type | Description | Pattern |
|--------|-----------|------|-------------|---------|
| phylowgsinput | meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| phylowgsinput | cnv_data.txt | file | cnv_data.txt and ssm_data.txt | *.txt |
| phylowgsinput | ssm_data.txt | file | cnv_data.txt and ssm_data.txt | *.txt |
| versions | versions.yml | file | File containing software versions | versions.yml |

## Authors

@pintoa1-mskcc

## Maintainers

@pintoa1-mskcc

