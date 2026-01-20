# Module: fgbio_collectduplexseqmetrics

Collects a suite of metrics to QC duplex sequencing data.

**Keywords:**

| Keywords |
|----------|
| duplex |
| sequencing |
| genomics |
| fgbio |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| fgbio | A set of tools for working with genomic and high throughput sequencing data, including UMIs | MIT | https://github.com/fulcrumgenomics/fgbio |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. [ id:test, single_end:false ]  |  |

## Outputs

| Output | Suboutput | Type | Description | Pattern |
|--------|-----------|------|-------------|---------|
| family_sizes | meta | map | Groovy Map containing sample information e.g. [ id:test, single_end:false ]  |  |
| family_sizes | ${prefix}.family_sizes.txt | map | Metrics on the frequency of different types of families of different sizes. | *.family_sizes.txt |
| duplex_family_sizes | meta | map | Groovy Map containing sample information e.g. [ id:test, single_end:false ]  |  |
| duplex_family_sizes | ${prefix}.duplex_family_sizes.txt | file | Metrics on the frequency of duplex tag families by the number of observations from each strand. | *.duplex_family_sizes.txt |
| duplex_yield_metrics | meta | map | Groovy Map containing sample information e.g. [ id:test, single_end:false ]  |  |
| duplex_yield_metrics | ${prefix}.duplex_yield_metrics.txt | file | Summary QC metrics produced using 5%, 10%, 15%...100% of the data. | *.duplex_yield_metrics.txt |
| umi_counts | meta | map | Groovy Map containing sample information e.g. [ id:test, single_end:false ]  |  |
| umi_counts | ${prefix}.umi_counts.txt | file | Metrics on the frequency of observations of UMIs within reads and tag families. | *.umi_counts.txt |
| duplex_umi_counts | meta | map | Groovy Map containing sample information e.g. [ id:test, single_end:false ]  |  |
| duplex_umi_counts | ${prefix}.duplex_umi_counts.txt | file | Metrics on the frequency of observations of duplex UMIs within reads and tag families. | *.duplex_umi_counts.txt |
| versions | versions.yml | file | File containing software versions | versions.yml |

## Authors

@mikefeixu

## Maintainers

@mikefeixu

