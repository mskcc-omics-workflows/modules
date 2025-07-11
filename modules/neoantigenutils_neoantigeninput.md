# Module: neoantigenutils_neoantigeninput

This module take several inputs to the Lukza neoantigen pipeline and combines them into a single json file ready for input into their pipeline

**Keywords:**

| Keywords |
|----------|
| neoantigen |
| aggregate |
| genomics |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| neoantigen_utils | Collection of helper scripts for neoantigen processing |  | None |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information.  Maybe cohort and patient_id as well? e.g. `[ id:sample1, single_end:false ]`  |  |
| meta2 | map | Groovy Map containing sample information.  Maybe cohort and patient_id as well? e.g. `[ id:sample1, single_end:false ]`  |  |
| meta3 | map | Groovy Map containing sample information.  Maybe cohort and patient_id as well? e.g. `[ id:sample1, single_end:false ]`  |  |

## Outputs

| Output | Suboutput | Type | Description | Pattern |
|--------|-----------|------|-------------|---------|
| json | meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| json | *.json | file | output combined Json ready for input into the neoantigen pipeline | *.{json} |
| versions | versions.yml | file | File containing software versions | versions.yml |

## Authors

@johnoooh, @nikhil

## Maintainers

@johnoooh, @nikhil

