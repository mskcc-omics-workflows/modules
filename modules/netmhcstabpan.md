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
| netmhcpan |  Runs netMHCpan and outputs tsvs and STDout for mutated and wild type neoantigens | MIT | https://services.healthtech.dtu.dk/services/NetMHCpan-4.1/ |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| inputMaf | file | Maf outputtted by Tempo that was run through phyloWGS | *.{maf} |
| hlaString | string | HLA in string format. e.g. HLA-A24:02 |  |
| inputType | string | Allows netmhcstabpan to run in parallel. Should be MUT or WT, it will kick off two jobs. make a Channel.Of(MUT,WT) outside the module as an input. Running them in series is kicked off by putting in anything other than MUT or WT. | * |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| versions | file | File containing software versions | versions.yml |
| netmhcstabpanoutput | file | STDOUT file of netMHCstabpan runs for MUT and WT.  A poorly formated file of neoantigens. Neoantigenutils contains a parser for this file | *.WT.netmhcstabpan.output,*.MUT.netmhcstabpan.output |

## Authors

@johnoooh, @nikhil

## Maintainers

@johnoooh, @nikhil

