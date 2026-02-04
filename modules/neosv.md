# Module: neosv

NEOSV is a program that takes a bedpe and outputs puntitave neoantiegns created from structural variants.  It has been modified so that it outputs fastas for later processing ny netmhcpan.

**Keywords:**

| Keywords |
|----------|
| immune |
| neosv |
| genomics |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| neosv |  Runs a modified version of NeoSV and outputs two multifastas.  One for mutated and another for wild type neoantigens | MIT | https://genomebiology.biomedcentral.com/articles/10.1186/s13059-023-03005-9 |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| gtf | file | Ensemble gtf resource file | *.{gtf.gz} |

## Outputs

| Output | Suboutput | Type | Description | Pattern |
|--------|-----------|------|-------------|---------|
| mutOut | meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| mutOut | *.net.in.txt | file | Mutated SV sequences in a multifasta | *.net.in.txt |
| wtOut | meta | map | Groovy Map containing sample information e.g. `[ id:sample1, single_end:false ]`  |  |
| wtOut | *.WT.net.in.txt | file | WT sequences in a multifasta | *.WT.net.in.txt |
| versions | versions.yml | file | File containing software versions | versions.yml |

## Authors

@johnoooh, @nikhil

## Maintainers

@johnoooh, @nikhil

