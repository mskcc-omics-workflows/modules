# Module: neoantigenediting_aligntoiedb

Align neoantigens to the IEDB file

**Keywords:**

| Keywords |
|----------|
| neoantigenediting |
| neoantigens |
| IEDB |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| neoantigenediting | Code for computing neoantigen qualities and for performing clone composition predictions. | None | https://www.nature.com/articles/s41586-022-04735-9 |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| iedb_fasta | file | IEDB epitopes used for analysis | *.fasta |

## Outputs

| Output | Suboutput | Type | Description | Pattern |
|--------|-----------|------|-------------|---------|
| iedb_alignment | meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| iedb_alignment | iedb_alignments_*.txt | file | IEDB alignment file | iedb_alignments_*.txt |
| versions | versions.yml | file | File containing software versions | versions.yml |

## Authors

@nikhil

## Maintainers

@nikhil

