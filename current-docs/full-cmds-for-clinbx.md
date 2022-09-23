# Full CMDs for ClinBx

#### Merge step

`/bin/zcat <Sample_Name>__L001_R2_001.fastq.gz <Sample_Name>_L002_R2_001.fastq.gz | /bin/gzip > <Sample_Name>_L000_R2_mrg.fastq.gz`

`/bin/zcat <Sample_Name>__L001_R1_001.fastq.gz <Sample_Name>_L002_R1_001.fastq.gz | /bin/gzip > <Sample_Name>_L000_R1_mrg.fastq.gz`

#### Trim step (dual barcode)

`python cutadapt -m 25 -e 0.1 -j 4 -a <AdaptorKey1> -A <AdaptorKey2> -o <Sample_Name>_L000_R1_mrg_cl.fastq.gz -p <Sample_Name>_L000_R2_mrg_cl.fastq.gz <Sample_Name>_L000_R1_mrg.fastq.gz <Sample_Name>_L000_R2_mrg.fastq.gz`

`Python version: Python 3.7.3; Cutadapt version: 2.5`

#### BWAMem step

`bwa mem -t 4 -PM -R '@RG\tID:<MRN>_<Project>\tLB:1258\tSM:<Sample_Name>\tPL:Illumina\tPU:bc1258\tCN:DMP_MSKCC' Homo_sapiens_assembly19.fasta <Sample_Name>_L000_R1_mrg_cl.fastq.gz <Sample_Name>_L000_R2_mrg_cl.fastq.gz`

`Output: <MRN>_L000_mrg_cl_aln.sam`

`BWA version: 0.7.5a-r405; Genome: hg19 generated on 20220226`

#### SS step

`java -Xmx10g -jar picard-tools-1.96/AddOrReplaceReadGroups.jar I=<MRN>_L000_mrg_cl_aln.sam O=<MRN>L000_mrg_cl_aln.bam SO=coordinate RGID=<MRN><Project> RGLB=1258 RGPL=Illumina RGPU=<Sample_Name> RGSM=<Sample_Name> RGCN=MSKCC TMPDIR=<Output_Dir> COMPRESSION_LEVEL=0 CREATE_INDEX=true VALIDATION_STRINGENCY=LENIENT`

`Java version: 1.7.0_09-icedtea; picard version: 1.96`

#### MarkDuplicates step

`java -Xmx7g -jar picard-tools-1.96/MarkDuplicates.jar I=<Sample_Name>_L000_mrg_cl_aln.bam O=<Sample_Name>_L000_mrg_cl_aln_srt_MD.bam ASSUME_SORTED=true METRICS_FILE=<Sample_Name>_L000_mrg_cl_aln_srt_MD.metrics TMP_DIR=<Output_Dir> COMPRESSION_LEVEL=0 CREATE_INDEX=true VALIDATION_STRINGENCY=LENIENT`

`Java version: 1.7.0_09-icedtea; picard version: 1.96`

#### FindCoveredIntervals step

`java -Xmx20g -jar GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar -T FindCoveredIntervals -R Homo_sapiens_assembly19.fasta -I <MRN>_IndelRealignerInput.list -minBQ 20 -minMQ 20 -cov 20 -o <MRN>_targetsToRealign_covered.list -rf FailsVendorQualityCheck -rf BadMate -rf UnmappedRead -rf BadCigar`

`Java version: 1.7.0_09-icedtea; Genome: hg19 generated on 20220226; GATK: 3.3-0`

#### ABRA step

`java -Xmx45G -jar abra-0.92-SNAPSHOT-jar-with-dependencies.jar --in <Sample_Name>_L000_mrg_cl_aln_srt_MD.bam --out <Sample_Name>_L000_mrg_cl_aln_srt_MD_IR.bam --ref Homo_sapiens_assembly19.fasta --targets <MRN>_targetsToRealign_covered_srt.bed --threads 8 --working <Output_Dir>/tmp_abra/ --kmer 43,53,63,83,93`

`Java version: 1.7.0_09-icedtea; Genome: hg19 generated on 20220226; ABRA version: 0.92`

#### FixMate step

`java -Xmx20g -jar picard-tools-1.96/FixMateInformation.jar I=<Sample_Name>_L000_mrg_cl_aln_srt_MD_IR.bam O=<Sample_Name>_L000_mrg_cl_aln_srt_MD_IR.bam.tmp SO=coordinate TMP_DIR=/dmp/analysis/SCRATCH/ COMPRESSION_LEVEL=0 CREATE_INDEX=true VALIDATION_STRINGENCY=LENIENT`

`Java version: 1.7.0_09-icedtea; picard version: 1.96`

#### BQSR step

`java -Xmx20g -Djava.io.tmpdir=<Output_Dir> -jar GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar -T BaseRecalibrator -nct 3 -I <Sample_Name>_L000_mrg_cl_aln_srt_MD_IR.bam -R Homo_sapiens_assembly19.fasta -knownSites dbsnp.vcf -knownSites Mills_and_100G_gold_standard.indels.vcf -rf BadCigar -o <Sample_Name>_L000_mrg_cl_aln_srt_recalReport.grp`

`Java version: 1.7.0_09-icedtea; Genome: hg19 generated on 20220226; GATK: 3.3-0; dbsnp: dbsnp_137.b37.vcf; mills-and-1000g: v20131014`

#### PBQSR step

`java -Xmx7g -Djava.io.tmpdir=<Output_Dir> -jar GenomeAnalysisTK-3.3-0/GenomeAnalysisTK.jar -T PrintReads -I <Sample_Name>_L000_mrg_cl_aln_srt_MD_IR.bam -R Homo_sapiens_assembly19.fasta -baq RECALCULATE -BQSR <Sample_Name>_L000_mrg_cl_aln_srt_recalReport.grp -EOQ -o <Sample_Name>_L000_mrg_cl_aln_srt_MD_IR_BR.bam`

`Java version: 1.7.0_09-icedtea; Genome: hg19 generated on 20220226; GATK: 3.3-0`

``

``

``

``

``
