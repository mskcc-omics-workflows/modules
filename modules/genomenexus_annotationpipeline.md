# Module: genomenexus_annotationpipeline

Second module in genome nexus java pipeline to perform annotation of a MAF file type using the genomenexus suite of conversion and annotation tools. Genome Nexus is a comprehensive one-stop resource for fast, automated and high-throughput annotation and interpretation of genetic variants in cancer. Genome Nexus integrates information from a variety of existing resources, including databases that convert DNA changes to protein changes, predict the functional effects of protein mutations, and contain information about mutation frequencies, gene function, variant effects, and clinical actionability.

**Keywords:**

| Keywords |
|----------|
| annotate |
| vcf |
| maf |
| genomenexus |
| genomics |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| genomenexus | Second module in genome nexus java pipeline to perform an annotation of MAF file type using the genomenexus suite of conversion and annotation tools. Genome Nexus is a comprehensive one-stop resource for fast, automated and high-throughput annotation and interpretation of genetic variants in cancer. Genome Nexus integrates information from a variety of existing resources, including databases that convert DNA changes to protein changes, predict the functional effects of protein mutations, and contain information about mutation frequencies, gene function, variant effects, and clinical actionability. | None | https://github.com/genome-nexus/genome-nexus-annotation-pipeline/ |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:test ]`  |  |
| input_maf | file | input MAF file | *.{maf} |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:test ]`  |  |
| versions | file | File containing software versions | versions.yml |
| maf | file | Output annotated MAF file | *.{maf} |

## Authors

@rnaidu

## Maintainers

@rnaidu

