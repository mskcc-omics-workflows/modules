# Subworkflow: generate_mutated_peptides

Generate mutated peptides from an annotated MAF

**Keywords:**

| Keywords |
|----------|
| peptides |
| maf |
| neoantigen |
| fasta |

## Components

| Components |
| ---------- |
| mutalyzer/retriever |
| generatemutfasta/1.2 |
| neoantigenutils/generatemutfasta |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| ch_maf_hla_sv | object | Object containing sample metadata and input files. Properties:   - meta: Groovy Map containing sample information, e.g. [ id:sample1, single_end:false ]   - maf: The input containing the maf file   - hla: The input containing the hla file   - sv: The input containing the sv file  | *.{maf,hla.txt,bedpe} |
| ref_fasta | file | A gzipped Human fasta file, ideally compressed with bgzip | *.{fa.gz,fasta.gz,fa.bgz} |
| gff3 | file | Gff3 file representing human annotation | *.gff3 |
| gtf | file | Ensemble gtf resource file | *.{gtf.gz} |
| cdna | file | The resource channel containing the cdna file | *.{fa.gz} |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| mut_fasta | file | Mutated fasta sequence output. Contains: meta (Groovy Map with sample information) and mutated sequences file  | *_out/*.MUT.sequences.fa |
| wt_fasta | file | Wildtype fasta sequence output. Contains: meta (Groovy Map with sample information) and wildtype sequences file  | *_out/*.WT.sequences.fa |
| mut_fasta_log | file | Log file for the mutated fasta generation. Contains: meta (Groovy Map with sample information) and generation log  | *_out/*_generate_mut_fasta.log |
| versions | file | File containing software versions | versions.yml |

## Authors

@nikhil

