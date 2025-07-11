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

## Outputs

| Output | Suboutput | Type | Description | Pattern |
|--------|-----------|------|-------------|---------|
| neoantigenTSV | meta | map | Groovy Map containing sample information e.g. `[ id:sample1]`  |  |
| neoantigenTSV | *.tsv | file | A reformatted file of neoantigens, now in TSV format! | *.{tsv} |
| versions | versions.yml | file | File containing software versions | versions.yml |

## Authors

@johnoooh

## Maintainers

@johnoooh, @nikhil

