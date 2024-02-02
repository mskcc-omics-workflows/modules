# Subworkflow: bwa_markdup_bqsr

A subworkflow for generating a BAM file from FASTQ

**Keywords:**

| Keywords |
|----------|
| bam |
| alignment |
| markduplicates |
| bqsr |
| duplicates |

## Components

| Components |
| ---------- |
| bwa/mem |
| gatk4/markduplicates |
| gatk4/applybqsr |
| gatk4/baserecalibrator |
| samtools/index |
| gatk4/markduplicates/spark |
| gatk4/applybqsr/spark |
| gatk4/baserecalibrator/spark |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| reads | None | An input channel containing fastq.gz files Structure: [ val(meta), path(reads)]  | *.{fastq.gz} |
| fasta | None | A channel containing the reference FASTA file Structure: [ path(fasta) ]  | *.{fasta,fa} |
| fai | None | A channel containing the index of the reference FASTA file Structure: [ path(fai) ]  | *.{fai} |
| bwa_index | None | A channel containing bwa index reference, which can be created using bwa/index Structure: [ val(meta2), path(bwa_index) ]  | *.{amb,ann,bwt,pac,sa} |
| dict | None | A channel containing a sequence dictionary file (`dict`), which can be created using gatk4/createsequencedictionary  Structure: [ path(blacklist) ]  | *.{dict} |
| known_sites | None | A channel containing one or more files containing known polymorphic sites that should be excluded during base recalibration.  Structure: [ path([known_sites_1, known_sites_2]) ]  | *.vcf.gz |
| known_sites_tbi | None | A channel containing tabix index files of the known_sites files Structure: [ path([known_sites_1_tbi, known_sites_2_tbi]) ]  | *.vcf.gz.tbi |
| spark | boolean | If true use spark gatk4 modules: GATK4_MARKDUPLICATES_SPARK, GATK4_APPLYBQSR_SPARK, GATK4_BASERECALIBRATOR_SPARK  | true|false |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| bam | None | BAM file with marked duplicates and BQSR Structure: [ val(meta), path(bam) ]  |  |
| bai | None | BAM index file Structure: [ val(meta), path(bai) ]  |  |
| versions | file | File containing software versions | versions.yml |

## Authors

@anoronh4

