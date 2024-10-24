# Module: neoantigenutils_convertannotjson

Takes the output of the neoantigen ediitng subworkflow and converts the annotated neoantigens to tsv format.

**Keywords:**

| Keywords |
|----------|
| neoantigen |
| tsv |
| peptides |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| neoantigen_utils | Collection of helper scripts for neoantigen processing |  | None |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information. e.g. `[ id:sample1]`  |  |
| annotatedJSON | file | Json annotated by the neoantigenediting subworkflow | *annotated.json |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1]`  |  |
| versions | file | File containing software versions | versions.yml |
| neoantigenTSV | file | A reformatted file of neoantigens, now in TSV format! | *.{tsv} |

## Authors

@johnoooh

## Maintainers

@johnoooh, @nikhil

