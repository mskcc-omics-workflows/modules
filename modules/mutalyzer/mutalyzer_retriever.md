# Module: mutalyzer_retriever

Generate the mutalyzer cache from a genomic annotation data source

**Keywords:**

| Keywords |
|----------|
| annotation |
| fasta |
| gff3 |
| Ensembl |
| RefSeq |
| Mutalyzer |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| mutalyzer | A tool primarily designed to check descriptions of sequence variants according to the Human Genome Sequence Variation Society (HGVS) guidelines. | MIT | None |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing resource information e.g. `[ id:resource_id ]`  |  |

## Outputs

| Output | Suboutput | Type | Description | Pattern |
|--------|-----------|------|-------------|---------|
| mutalyzer_cache | *.tar.gz | file | Mutatalyzer cache to use with the normalizer | *.tar.gz |
| versions | versions.yml | file | File containing software versions | versions.yml |

## Authors

@nikhil

## Maintainers

@nikhil, @johnoooh

