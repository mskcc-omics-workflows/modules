# Module: pvmaf_tagtraceback

a flexible command for tagging maf files

**Keywords:**

| Keywords |
|----------|
| tagging |
| maf |
| msk-access |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| pvmaf | provides a variety of commands for manipulating mafs. | MIT | https://github.com/msk-access/postprocessing_variant_calls |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, patient:patient1 ]`  |  |
| maf | file | Maf file with columns required for selected tagging type. | *.{maf} |
| path(sample_sheets) | file | Samplesheet with `sample_id` and `type` columns. Used to add fillout type information to provided maf. See Nucleovar for more info: https://github.com/mskcc-omics-workflows/nucleovar/blob/main/README.md.  |  |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, patient:patient1 ]`  |  |
| versions | file | File containing software versions | versions.yml |
| maf | file | tagged traceback maf. | *.{maf} |

## Authors

@buehlere

## Maintainers

@buehlere

