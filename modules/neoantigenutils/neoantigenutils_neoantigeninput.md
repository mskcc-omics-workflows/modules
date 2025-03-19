# Module: neoantigenutils_neoantigeninput

This module take several inputs to the Lukza neoantigen pipeline and combines them into a single json file ready for input into their pipeline

**Keywords:**

| Keywords |
|----------|
| neoantigen |
| aggregate |
| genomics |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| neoantigen_utils | Collection of helper scripts for neoantigen processing |  | None |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information.  Maybe cohort and patient_id as well? e.g. `[ id:sample1, single_end:false ]`  |  |
| inputMaf | file | Maf outputtted by Tempo that was run through phyloWGS | *.{maf} |
| phyloWGSsumm | file | Summ json outputtted by phyloWGS | *.{json.gz} |
| phyloWGSmut | file | Summary json outputtted by phyloWGS | *.{json.gz} |
| phyloWGSfolder | file | Folder of mutations in trees output by PhyloWGS | .{zip} |
| mutNetMHCpan | file | tsv formatted output from netMHCpan with the mutated neoantigens . | .{tsv} |
| wtNetMHCpan | file | tsv formatted STDOUT file of netMHCpan.  A poorly formated file of neoantigens.  This containes the wild type antigens | .{tsv} |
| hlaFile | file | HLA tsv outputtted by Polysolver | winners.{tsv} |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| versions | file | File containing software versions | versions.yml |
| json | file | output combined Json ready for input into the neoantigen pipeline | *.{json} |

## Authors

@johnoooh, @nikhil

## Maintainers

@johnoooh, @nikhil

