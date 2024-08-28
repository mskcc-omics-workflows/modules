# Module: genotypevariants_all

write your description here

**Keywords:**

| Keywords |
|----------|
| genotype |
| bams |
| maf |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| genotypevariants | module supports genotyping and merging small variants (SNV and INDELS). | MIT | None |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, patient:patient_1 ]`  |  |
| bam_standard | file | Full path to standard bam file. | *.{bam} |
| bai_standard | file | Requires the standard .bai file is present at same location as the bam file. | *.{bai} |
| bam_duplex | file | Full path to duplex bam file. | *.{bam} |
| bai_duplex | file | Requires the duplex .bai file is present at same location as the bam file. | *.{bai} |
| bam_simplex | file | Full path to simplex bam file. | *.{bam} |
| bai_simplex | file | Requires the simplex .bai file is present at same location as the bam file. | *.{bai} |
| maf | file | Full path to small variants input file in MAF format | *.{maf} |
| fasta | file | The reference fasta file | *.fasta |
| fai | file | Index of reference fasta file | *.fasta.fai |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, patient:patient_1 ]`  |  |
| maf | file | Genotyped maf for each bam provided and a merged genotyped maf. The mafs will be labelled with patient identifier or sample identifier as the prefix, and end with the type of bam (duplex, simplex, or standard). The sample identifier is prioritized. | *.{mafs} |
| versions | file | File containing software versions | versions.yml |

## Authors

@buehlere

## Maintainers

@buehlere

