# Module: calculatenoise

Performs noise calculation for ACCESSv2 standard BAM files

**Keywords:**

| Keywords |
|----------|
| calculate |
| noise |
| ACCESS |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| calculatenoise | Performs noise calculation for ACCESSv2 standard BAM files | MIT | https://github.com/msk-access/sequence_qc |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. [ id:test, single_end:false ]  |  |
| fasta | file | Input reference sequence file | *.fasta |
| fai | file | Index of the reference Fasta | *.fai |

## Outputs

| Output | Suboutput | Type | Description | Pattern |
|--------|-----------|------|-------------|---------|
| acgt | meta | map | Groovy Map containing sample information e.g. [ id:test, single_end:false ]  |  |
| acgt | ${prefix}_acgt.tsv | map | noise metrics | *_acgt.tsv |
| substitution | meta | map | Groovy Map containing sample information e.g. [ id:test, single_end:false ]  |  |
| substitution | *_substitution.tsv | file | noise metrics | *_substitution.tsv |
| bytlen | meta | map | Groovy Map containing sample information e.g. [ id:test, single_end:false ]  |  |
| bytlen | *_by_tlen.tsv | file | noise metrics | *_by_tlen.tsv |
| del | meta | map | Groovy Map containing sample information e.g. [ id:test, single_end:false ]  |  |
| del | *_del.tsv | file | noise metrics | *_del.tsv |
| count | meta | map | Groovy Map containing sample information e.g. [ id:test, single_end:false ]  |  |
| count | *_n.tsv | file | noise metrics | *_n.tsv |
| positions | meta | map | Groovy Map containing sample information e.g. [ id:test, single_end:false ]  |  |
| positions | *_positions.tsv | file | noise metrics | *_positions.tsv |
| positions | meta | map | Groovy Map containing sample information e.g. [ id:test, single_end:false ]  |  |
| positions | *_positions.tsv | file | noise metrics | *_positions.tsv |
| html | meta | map | Groovy Map containing sample information e.g. [ id:test, single_end:false ]  |  |
| html | *_noise.html | file | noise metrics | *_noise.html |
| pileup | meta | map | Groovy Map containing sample information e.g. [ id:test, single_end:false ]  |  |
| pileup | *_pileup.tsv | file | noise metrics | *_pileup.tsv |
| versions | versions.yml | file | File containing software versions | versions.yml |

## Authors

@mikefeixu

## Maintainers

@mikefeixu

