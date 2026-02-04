# Subworkflow: netmhcstabandpan

Run netmhcpan and netmhcstabpan in parallel.

**Keywords:**

| Keywords |
|----------|
| peptides |
| netmhc |
| neoantigen |
| tsv |

## Components

| Components |
| ---------- |
| netmhc3 |
| netmhcpan4 |
| netmhcstabpan |
| neoantigenutils/formatnetmhcpan |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| ch_fasta_and_hla | file | The input channel containing the fasta and hla files Structure: [ val(meta), path(mut_fasta), path(wt_fasta), path(hla) ]  | *.{fa/txt} |
| ch_sv_fasta | file | The input channel containing the structural variant fasta files Structure: [ val(meta), path(sv_mut_fasta), path(sv_wt_fasta) ]  | *.{fa} |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| tsv | file | Channel containing TSV files Structure: [ val(meta), path(tsv) ]  | *.tsv |
| versions | file | File containing software versions Structure: [ path(versions.yml) ]  | versions.yml |

## Authors

@nikhil

