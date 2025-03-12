# Module: netmhcpan4

Predicts binding of neoantigen peptides

**Keywords:**

| Keywords |
|----------|
| immune |
| netmhcpan |
| genomics |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| netmhcpan |  Runs netMHCpan and outputs tsvs and STDout for mutated and wild type neoantigens | MIT | https://services.healthtech.dtu.dk/services/NetMHCpan-4.1/ |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |

## Outputs

| Output | Suboutput | Type | Description | Pattern |
|--------|-----------|------|-------------|---------|
| xls | output_meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| xls | *.xls | file | XLS file of netMHC. A poorly formated file of neoantigens. This contains the MUT or WT antigens | *.WT.xls,*.MUT.xls |
| netmhcpanoutput | output_meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  | *.WT.netmhcpan.output,*.MUT.netmhcpan.output |
| netmhcpanoutput | *.netmhcpan.output | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  | *.WT.netmhcpan.output,*.MUT.netmhcpan.output |
| versions | versions.yml | file | File containing software versions | versions.yml |

## Authors

@johnoooh, @nikhil

## Maintainers

@johnoooh, @nikhil

