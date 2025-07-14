# Module: genomenexus_annotationpipeline

DSL2 module to perform annotation of a MAF file type using the genomenexus suite of conversion and annotation tools.

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
| genomenexus | DSL2 module to perform an annotation of MAF file type using the genomenexus suite of conversion and annotation tools. | None | https://github.com/genome-nexus/genome-nexus-annotation-pipeline/ |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:test ]`  |  |

## Outputs

| Output | Suboutput | Type | Description | Pattern |
|--------|-----------|------|-------------|---------|
| annotated_maf | meta | map | Groovy Map containing sample information e.g. `[ id:test ]`  | *_annotated.{maf} |
| annotated_maf | *.maf | map | Groovy Map containing sample information e.g. `[ id:test ]`  | *_annotated.{maf} |
| versions | versions.yml | file | File containing software versions | versions.yml |

## Authors

@rnaidu

## Maintainers

@rnaidu

