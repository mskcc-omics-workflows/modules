# Module: gatk4_applybqsr

Apply base quality score recalibration (BQSR) to a bam file

**Keywords:**

| Keywords |
|----------|
| bam |
| base quality score recalibration |
| bqsr |
| cram |
| gatk4 |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| gatk4 | Developed in the Data Sciences Platform at the Broad Institute, the toolkit offers a wide variety of tools with a primary focus on variant discovery and genotyping. Its powerful processing engine and high-performance computing features make it capable of taking on projects of any size.  | Apache-2.0 | https://gatk.broadinstitute.org/hc/en-us |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. [ id:test, single_end:false ]  |  |
| input | file | BAM/CRAM file from alignment | *.{bam,cram} |
| input_index | file | BAI/CRAI file from alignment | *.{bai,crai} |
| bqsr_table | file | Recalibration table from gatk4_baserecalibrator |  |
| intervals | file | Bed file with the genomic regions included in the library (optional) |  |
| fasta | file | The reference fasta file | *.fasta |
| fai | file | Index of reference fasta file | *.fasta.fai |
| dict | file | GATK sequence dictionary | *.dict |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. [ id:test, single_end:false ]  |  |
| versions | file | File containing software versions | versions.yml |
| bam | file | Recalibrated BAM file | *.{bam} |
| cram | file | Recalibrated CRAM file | *.{cram} |

## Authors

@yocra3, @FriederikeHanssen

## Maintainers

@yocra3, @FriederikeHanssen

