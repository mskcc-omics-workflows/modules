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
| inputMaf | file | Maf outputtted by Tempo that was run through phyloWGS | *.{maf} |
| cds | file | coding sequence resource fasta | *.{cds.all.fa.gz} |
| cdna | file | cDNA resource fasta | *.{cdna.all.fa.gz} |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| versions | file | File containing software versions | versions.yml |
| json | file | output combined Json ready for input into the neoantigen pipeline | *.{json} |
| mut_fasta | file | Mutated fasta sequence | *.{MUT_sequences.fa} |
| wt_fasta | file | Wildtype fasta sequence | *.{WT_sequences.fa} |

## Authors

@johnoooh, @nikhil

## Maintainers

@johnoooh, @nikhil

