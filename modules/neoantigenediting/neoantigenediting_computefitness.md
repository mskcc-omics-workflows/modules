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
| patient_data | file | Patient data consisting of mutation, neoantigen, and tree information | *.json |
| alignment | file | IEDB alignment file | iedb_alignments_*.txt |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| annotated_output | file | Output containing neoantigen quality scores | *_annotated.json |
| versions | file | File containing software versions | versions.yml |

## Authors

@nikhil

## Maintainers

@nikhil

