# Module: neoantigenediting_computefitness

Compute fitness of the neoantigens

**Keywords:**

| Keywords |
|----------|
| neoantigenediting |
| neoantigens |
| fitness |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| neoantigenediting | Code for computing neoantigen qualities and for performing clone composition predictions. | None | https://www.nature.com/articles/s41586-022-04735-9 |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |

## Outputs

| Output | Suboutput | Type | Description | Pattern |
|--------|-----------|------|-------------|---------|
| annotated_output | meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| annotated_output | *_annotated.json | file | Output containing neoantigen quality scores | *_annotated.json |
| versions | versions.yml | file | File containing software versions | versions.yml |

## Authors

@nikhil

## Maintainers

@nikhil

