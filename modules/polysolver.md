# Module: polysolver

HLA class I genotyping

**Keywords:**

| Keywords |
|----------|
| hla |
| genotyping |
| bam |

**Tools:**

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| polysolver | HLA typing | GPL v3 | https://software.broadinstitute.org/cancer/cga/polysolver |

**Inputs:**

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| bam | file | Sorted BAM file | *.{bam,cram,sam} |
| includeFreq | integer | Flag indicating whether population-level allele frequencies should be used as priors (0 or 1) (Default: 1) |  |
| build | string | reference genome used in the BAM file (hg18 or hg19 or hg38) (Default: hg19) |  |
| format | string | fastq format (STDFQ, ILMFQ, ILM1.8 or SLXFQ; see Novoalign documentation) (Default: STDFQ) |  |
| insertCalc | integer | flag indicating whether empirical insert size distribution should be used in the model (0 or 1) (Default: 0) |  |

**Outputs:**

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| versions | file | File containing software versions | versions.yml |
| hla | file | Polysolver HLA genotyping result | *.hla.txt |

**Authors:**

@anoronh4

**Maintainers:**

@anoronh4

