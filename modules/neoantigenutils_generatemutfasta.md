# Module: neoantigenutils_generatemutfasta

Generate the mutation fasta for netmhc tools

**Keywords:**

| Keywords |
|----------|
| neoantigen |
| fasta |
| netmhc |
| mutation |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| neoantigen_utils | Collection of helper scripts for neoantigen processing |  | None |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information. e.g. `[ id:sample1, single_end:false ]`  |  |
| cds | file | coding sequence resource fasta | *.{cds.all.fa.gz} |

## Outputs

| Output | Suboutput | Type | Description | Pattern |
|--------|-----------|------|-------------|---------|
| mut_fasta | meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| mut_fasta | *_out/*.MUT.sequences.fa | file | Mutated fasta sequence | *.{MUT.sequences.fa} |
| wt_fasta | meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| wt_fasta | *_out/*.WT.sequences.fa | file | Wildtype fasta sequence | *.{WT.sequences.fa} |
| versions | versions.yml | file | File containing software versions | versions.yml |

## Authors

@johnoooh, @nikhil

## Maintainers

@johnoooh, @nikhil

