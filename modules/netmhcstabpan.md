# Module: netmhcstabpan

Runs netMHCpan and netMHCstabpan and outputs STDout for mutated and wild type neoantigens"

**Keywords:**

| Keywords |
|----------|
| immune |
| netmhcstabpan |
| netMHCstabpan |
| genomics |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| netmhcstabpan |  Runs netMHCstabpan and netMHCpan then outputs tsvs and STDout for mutated and wild type neoantigens | MIT | https://services.healthtech.dtu.dk/services/NetMHCstabpan-1.0/ |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |

## Outputs

| Output | Suboutput | Type | Description | Pattern |
|--------|-----------|------|-------------|---------|
| netmhcstabpanoutput | output_meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| netmhcstabpanoutput | *.netmhcstabpan.output | file | STDOUT file of netMHCstabpan runs for MUT and WT.  A poorly formated file of neoantigens. Neoantigenutils contains a parser for this file | *.WT.netmhcstabpan.output,*.MUT.netmhcstabpan.output |
| versions | versions.yml | file | File containing software versions | versions.yml |

## Authors

@johnoooh, @nikhil

## Maintainers

@johnoooh, @nikhil

