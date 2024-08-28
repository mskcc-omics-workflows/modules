# Subworkflow: traceback

Genotype access and/or impact bams by a concatenated list of mafs. If patient ids are provided, access and/or impact bams are genotyped by concatenated mafs with matching patient ids.

**Keywords:**

| Keywords |
|----------|
| maf |
| bam |
| traceback |
| impact |
| access |
| genotyping |

## Components

| Components |
| ---------- |
| genotypevariants/all |
| pvmaf/concat |
| pvmaf/tagtraceback |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| bams | channel | An input channel containing impact or access bams files: impact: Channel.of([patient:null, id:sample], standard.bam, standard.bam.bai, [], [], [], []) access: Channel.of([patient:null, id:sample], [], [], duplex.bam, duplex.bam.bai, simplex.bam, simplex.bam.bai])  | *.{bam/cram/sam} |
| mafs | channel | An input channel containing maf files Structure: // channel: Channel.of([[patient:null, id:sample], [maf1,...,maf2]], [[patient:null, id:sample], [maf1,...,maf2] ]])  | *.{maf,txt,tsv} |
| fasta | file | A file containing the reference FASTA file Structure: path(fasta)  | *.{fasta,fa} |
| fai | file | A file containing the index of the reference FASTA file Structure: path(fai)  | *.{fai} |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| genotyped_maf | map | Groovy Map containing combined genotyped maf for all provided bams. Structure: [ val(meta), path(maf) ]  | *.maf |
| individual_genotyped_mafs | map | Groovy Map containing genotyped mafs for each provided bam. Structure: [ val(meta), [maf,..,maf] ]  | *.maf |
| versions | file | File containing software versions Structure: [ path(versions.yml) ]  | versions.yml |

## Authors

@buehlere

