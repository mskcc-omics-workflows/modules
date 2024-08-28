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
| neoantigenutils/generatehlastring |
| neoantigenutils/generatemutfasta |
| netmhcpan |
| netmhcstabpan |
| neoantigenutils/formatnetmhcpan |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| ch_maf_and_hla | file | The input channel containing the maf and files Structure: [ val(meta), path(maf), path(hla) ]  | *.{maf/txt} |
| ch_cds_and_cdna | file | The resource channel containing the cds and cdna files Structure: [ path(cds) , path(cdna) ]  | *.{fa.gz} |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| tsv | file | Channel containing TSV files Structure: [ val(meta), path(tsv) ]  | *.tsv |
| xls | file | Channel containing XLS files Structure: [ val(meta), path(xls) ]  | *.xls |
| mut_fasta | file | Channel containing the MUT fasta files Structure: [ val(meta), path(mut_fasta) ]  | *.fa |
| wt_fasta | file | Channel containing the WT fasta files Structure: [ val(meta), path(wt_fasta) ]  | *.fa |
| versions | file | File containing software versions Structure: [ path(versions.yml) ]  | versions.yml |

## Authors

@nikhil

