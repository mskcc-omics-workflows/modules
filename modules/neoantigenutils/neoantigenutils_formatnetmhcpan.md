# Module: neoantigenutils_formatnetmhcpan

Takes the standard out of netmhcpan tools and converts them to a tsv for downstream processing

**Keywords:**

| Keywords |
|----------|
| neoantigen |
| tsv |
| peptides |
| netmhc |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| neoantigen_utils | Collection of helper scripts for neoantigen processing |  | None |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information. typeMut indicated if a mutated fasta was used fromStab indicates if the output was from netmhcstabpan e.g. `[ id:sample1, typeMut: false, fromStab: false ]`  |  |

## Outputs

| Output | Suboutput | Type | Description | Pattern |
|--------|-----------|------|-------------|---------|
| netMHCpanreformatted | meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| netMHCpanreformatted | *.tsv | file | A reformatted file of neoantigens and their binding affinities output by netmhcpan or netmhcstabpan.  This contains the wild type antigens | *.{tsv} |
| versions | versions.yml | file | File containing software versions | versions.yml |

## Authors

@johnoooh, @nikhil

## Maintainers

@johnoooh, @nikhil

