# Module: facets

Algorithm to implement Fraction and Allele specific Copy number Estimate from Tumor/normal Sequencing.

**Keywords:**

| Keywords |
|----------|
| facets |
| pileup |
| Allele specific |
| Copy number |

## Tools

| Tool | Description | License | Homepage |
|------|-------------|---------|----------|
| facets-suite | An R package with functions to run | MIT | https://github.com/mskcc/facets-suite |
| facets | Algorithm to implement Fraction and Allele specific Copy number Estimate from Tumor/normal Sequencing. | None | https://github.com/mskcc/facets |

## Inputs

| Input | Type | Description | Pattern |
|-------|------|-------------|---------|
| meta | map | Groovy Map containing sample information e.g. `[ id:pair_id ]`  |  |
| snp_pileup | file | The pileup file | *.snp_pileup.gz |
| legacy_output_mode | boolean | Flag to run Facets in legacy output mode |  |

## Outputs

| Output | Type | Description | Pattern |
|--------|------|-------------|---------|
| purity_seg | file | The purity seg file | *_purity.seg |
| purity_rdata | file | The purity R data file. This could be an .Rdata (legacy output) or .rds (original output) | *_purity.?d* |
| purity_png | file | The purity png file. In legacy output the file would match *.CNCF.png | *_purity*png |
| purity_out | file | The purity out file. Only in legacy output mode. | *_purity.out |
| purity_cncf_txt | file | The purity cncf file. Only in legacy output mode. | *_purity.cncf.txt |
| hisens_seg | file | The hisens seg file | *_hisens.seg |
| hisens_rdata | file | The hisens R data file. This could be an .Rdata (legacy output) or .rds (original output) | *_hisens.?d* |
| hisens_png | file | The hisens png file. In legacy output the file would match *.CNCF.png | *_hisens*png |
| hisens_out | file | The hisense out file. Only in legacy output mode. | *_hisens.out |
| hisens_cncf_txt | file | The hisens cncf file. Only in legacy output mode. | *_hisens.cncf.txt |
| qc_txt | file | The qc file | *.qc.txt |
| gene_level_txt | file | The gene level file | *.gene_level.txt |
| arm_level_txt | file | The arm level file | *.arm_level.txt |
| output_txt | file | The facets output log file. Format [id].txt | *.txt |
| versions | file | File containing software versions | versions.yml |

## Authors

@nikhil

## Maintainers

@nikhil

