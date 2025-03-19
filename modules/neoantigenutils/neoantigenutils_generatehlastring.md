# Module: neoantigenutils_generatehlastring

Generate the hla string for netmhc tools

**Keywords:**

| Keywords |
|----------|
| neoantigen |
| string |
| netmhc |
| hla |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| neoantigen_utils | Collection of helper scripts for neoantigen processing |  | None |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information. e.g. `[ id:sample1, single_end:false ]`  |  |
| inputHLA | file | Winners HLA file from polysolver | *.{hla.txt} |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| versions | file | File containing software versions | versions.yml |
| hlastring | string | HLA string to use for netmhc tool input |  |

## Authors

@johnoooh, @nikhil

## Maintainers

@johnoooh, @nikhil

