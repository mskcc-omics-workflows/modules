# Module: custom_splitfastqbylane

Split fastq into multiple fastqs by lane

**Keywords:**

| Keywords |
|----------|
| awk |
| fastq |
| split |

**Tools:**

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| custom | GNU awk | GPL v3 | https://www.gnu.org/software/gawk/manual/gawk.html |

**Inputs:**

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| reads | file | Paired end or single end FASTQ file(s) | *.{fastq,fastq.gz} |

**Outputs:**

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| versions | file | File containing software versions | versions.yml |
| reads | file | Output fastq files containing only one read lane per file. | *.{split.fastq.gz} |

**Authors:**

@anoronh4

**Maintainers:**

@anoronh4

