# Module: netmhcpan

write your description here

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
| inputMaf | file | Maf outputtted by Tempo that was run through phyloWGS | *.{maf} |
| hlaFile | file | HLA tsv outputtted by Polysolver | winners.{tsv} |
| inputType | string | Allows netmhcpan to run in parallel. Should be MUT or WT, it will kick off two jobs. make a Channel.Of(MUT,WT) outside the module as an input. Running them in series is kicked off by putting in anything other than MUT or WT. | * |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| versions | file | File containing software versions | versions.yml |
| xls | file | TSV/XLS file of netMHCpan.  A poorly formated file of neoantigens.  This contains the MUT or WT antigens | *.xls |
| netmhcpanoutput | file | STDOUT file of netMHCpan.  A poorly formated file of neoantigens.  This contains either the MUT or WT neoantigens. Neoantigenutils contains a parser for this file. | *.WT.netmhcpan.output,*.MUT.netmhcpan.output |

## Authors

@johnoooh, @nikhil

## Maintainers

@johnoooh, @nikhil

