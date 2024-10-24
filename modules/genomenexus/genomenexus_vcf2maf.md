# Module: genomenexus_vcf2maf

First module in genome nexus java pipeline to perform a native conversion of VCF file type to MAF file type using the genomenexus suite of conversion and annotation tools. Genome Nexus is a comprehensive one-stop resource for fast, automated and high-throughput annotation and interpretation of genetic variants in cancer. Genome Nexus integrates information from a variety of existing resources, including databases that convert DNA changes to protein changes, predict the functional effects of protein mutations, and contain information about mutation frequencies, gene function, variant effects, and clinical actionability.

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
| genomenexus | First module in genome nexus java pipeline to perform a native conversion of VCF file type to MAF file type using the genomenexus suite of conversion and annotation tools. Genome Nexus is a comprehensive one-stop resource for fast, automated and high-throughput annotation and interpretation of genetic variants in cancer. Genome Nexus integrates information from a variety of existing resources, including databases that convert DNA changes to protein changes, predict the functional effects of protein mutations, and contain information about mutation frequencies, gene function, variant effects, and clinical actionability. | None | https://github.com/genome-nexus |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:test, case_id:tumor, control_id:normal ]`  |  |
| vcf | file | input VCF file | *.{vcf} |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:test, case_id:tumor, control_id:normal ]`  |  |
| versions | file | File containing software versions | versions.yml |
| maf | file | Output MAF file | *.{maf} |

## Authors

@rnaidu

## Maintainers

@rnaidu

