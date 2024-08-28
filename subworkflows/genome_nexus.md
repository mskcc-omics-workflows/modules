# Subworkflow: genome_nexus

Subworkflow to perform conversion of VCF to MAF and annotation of said MAF file.

**Keywords:**

| Keywords |
|----------|
| annotate |
| convert |
| vcf |
| maf |
| genome_nexus |

## Components

| Components |
| ---------- |
| genomenexus/vcf2maf |
| genomenexus/annotationpipeline |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| ch_vcf | file | The input channel containing the input VCF file Structure: [ val(meta), path(vcf) ]  |  |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| maf | file | Channel containing output converted and annotated MAF file Structure: [ val(meta), path(maf) ]  |  |
| versions | file | File containing software versions Structure: [ path(versions.yml) ]  | versions.yml |

## Authors

@rnaidu

