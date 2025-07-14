# Module: genomenexus_vcf2maf

DSL2 module to perform a native conversion of VCF file type to MAF file type using the genomenexus suite of conversion and annotation tools.

**Keywords:**

| Keywords |
|----------|
| convert |
| vcf |
| maf |
| genomenexus |
| genomics |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| genomenexus | DSL2 module to perform a native conversion of VCF file type to MAF file type using the genomenexus suite of conversion and annotation tools. | None | https://github.com/genome-nexus |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:test, case_id:tumor, control_id:normal ]`  |  |

## Outputs

| Output | Suboutput | Type | Description | Pattern |
|--------|-----------|------|-------------|---------|
| maf | meta | map | Groovy Map containing sample information e.g. `[ id:test, case_id:tumor, control_id:normal ]`  |  |
| maf | vcf2maf_output/${meta.control_id}_${meta.case_id}_annotated.maf | file | Output MAF file | *.{maf} |
| versions | versions.yml | file | File containing software versions | versions.yml |

## Authors

@rnaidu

## Maintainers

@rnaidu

