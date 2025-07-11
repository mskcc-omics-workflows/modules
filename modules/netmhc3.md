# Module: netmhc3

Predicts binding of neoantigen peptides

**Keywords:**

| Keywords |
|----------|
| immune |
| netmhc |
| genomics |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| netmhc3 | Runs netMHC and outputs tsvs and STDout for mutated and wild type neoantigens | MIT | https://services.healthtech.dtu.dk/services/netmhc-4.1/ |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |

## Outputs

| Output | Suboutput | Type | Description | Pattern |
|--------|-----------|------|-------------|---------|
| netmhcoutput | output_meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| netmhcoutput | *.netmhc.output | file | STDOUT file of netMHC.  A poorly formated file of neoantigens.  This contains either the MUT or WT neoantigens. Neoantigenutils contains a parser for this file. | *.WT.netmhc.output,*.MUT.netmhc.output |
| xls | output_meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| xls | *.xls | file | XLS file of netMHC. A poorly formated file of neoantigens. This contains the MUT or WT antigens | *.WT.xls,*.MUT.xls |
| netmhc_hla_files | output_meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| netmhc_hla_files | *.hla_*.txt | file | STDOUT file of netMHC.  A poorly formated file of neoantigens.  This contains either the MUT or WT neoantigens. Neoantigenutils contains a parser for this file. | *.hla_accepted.txt,*.hla_rejected.txt |
| versions | versions.yml | file | File containing software versions | versions.yml |

## Authors

@johnoooh, @nikhil

## Maintainers

@johnoooh, @nikhil

