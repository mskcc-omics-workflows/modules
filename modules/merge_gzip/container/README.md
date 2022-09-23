## merge_gzip

#### Description:

Merge Fastq files from two lanes to one

#### Usage:

Inputs:

- <Sample_Name>\_L001_R1_001.fastq.gz
- <Sample_Name>\_L002_R1_001.fastq.gz

Outputs:

- <Sample_Name>\_L000_R1_mrg.fastq.gz

#### Reference

```
zcat <Sample_Name>__L001_R1_001.fastq.gz <Sample_Name>_L002_R1_001.fastq.gz | gzip > <Sample_Name>_L000_R1_mrg.fastq.gz
```
