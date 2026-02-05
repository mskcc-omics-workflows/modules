# Module: neoantigenutils_generatemutfasta

Generate the mutation fasta for netmhc tools

**Keywords:**

| Keywords |
|----------|
| neoantigen |
| fasta |
| netmhc |
| mutation |
| hgvsc |
| Mutalyzer |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| neoantigen_utils | Collection of helper scripts for neoantigen processing |  | None |
| mutalyzer | A tool primarily designed to check descriptions of sequence variants according to the Human Genome Sequence Variation Society (HGVS) guidelines. | MIT | None |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information. e.g. `[ id:sample1, single_end:false ]`  |  |
| mutalyzer_cache | file | Mutatalyzer cache to use with the normalizer | *.tar.gz |

## Outputs

| Output | Suboutput | Type | Description | Pattern |
|--------|-----------|------|-------------|---------|
| mut_fasta | meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| mut_fasta | *_out/*.MUT.sequences.fa | file | Mutated fasta sequence | *.MUT.sequences.fa |
| wt_fasta | meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| wt_fasta | *_out/*.WT.sequences.fa | file | Wildtype fasta sequence | *.WT.sequences.fa |
| mut_fasta_log | meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| mut_fasta_log | *_out/*_generate_mut_fasta.log | file | Log file for the mutated fasta generation | *_generate_mut_fasta.log |
| versions | versions.yml | file | File containing software versions | versions.yml |

## Authors

@johnoooh, @nikhil

## Maintainers

@johnoooh, @nikhil

