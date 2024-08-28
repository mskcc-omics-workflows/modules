# Subworkflow: phylowgs

Application for inferring subclonal composition and evolution from whole-genome and exome sequencing data

**Keywords:**

| Keywords |
|----------|
| CNVs |
| FACETs |
| mutations |
| clones |

## Components

| Components |
| ---------- |
| phylowgs/createinput |
| phylowgs/parsecnvs |
| phylowgs/multievolve |
| phylowgs/writeresults |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| ch_input_maf_and_genelevel | file | The input channel containing the maf and FACETS genelevel files Structure: [ val(meta), path(maf), path(genelevel) ]  | *.{maf/txt} |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| summ | file | Output file for JSON-formatted tree summaries | *.summ.json.gz |
| muts | file | Output file for JSON-formatted list of mutations | *.muts.json.gz |
| mutass | file | Output file for JSON-formatted list of SSMs and CNVs | *.mutass.zip |
| versions | file | File containing software versions Structure: [ path(versions.yml) ]  | versions.yml |

## Authors

@nikhil

