## merge_gzip

#### Description:

Merge Fastq files from two lanes to one

#### Usage:

Inputs:

- <Sample_Name>\_L001_R1_001.fastq.gz (usually) OR <Sample_Name>\_R2_001.fastq.gz (for fastq files without lane information)
- <Sample_Name>\_L002_R1_001.fastq.gz (usually) OR null (for fastq files without lane information)

Outputs:

- <Sample_Name>\_L000_R1_mrg.fastq.gz

#### Reference

```
zcat <Sample_Name>__L001_R1_001.fastq.gz <Sample_Name>_L002_R1_001.fastq.gz | gzip > <Sample_Name>_L000_R1_mrg.fastq.gz
```
