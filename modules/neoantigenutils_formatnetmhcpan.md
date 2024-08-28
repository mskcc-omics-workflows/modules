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
| netmhcOutput | file | Maf outputtted by Tempo that was run through phyloWGS | *.{output} |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| versions | file | File containing software versions | versions.yml |
| netMHCpanreformatted | file | A reformatted file of neoantigens and their binding affinities output by netmhcpan or netmhcstabpan.  This contains the wild type antigens | *.{tsv} |

## Authors

@johnoooh, @nikhil

## Maintainers

@johnoooh, @nikhil

