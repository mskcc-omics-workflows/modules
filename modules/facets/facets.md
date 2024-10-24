# facets

Algorithm to implement Fraction and Allele specific Copy number Estimate from Tumor/normal Sequencing.

**Keywords:**

| Keywords        |
| --------------- |
| facets          |
| pileup          |
| Allele specific |
| Copy number     |

## Tools

| Tool         | Description                                                                                            | License | Homepage                              |
| ------------ | ------------------------------------------------------------------------------------------------------ | ------- | ------------------------------------- |
| facets-suite | An R package with functions to run                                                                     | MIT     | https://github.com/mskcc/facets-suite |
| facets       | Algorithm to implement Fraction and Allele specific Copy number Estimate from Tumor/normal Sequencing. | None    | https://github.com/mskcc/facets       |

## Inputs

| Input                | Type    | Description                                                    | Pattern           |
| -------------------- | ------- | -------------------------------------------------------------- | ----------------- |
| meta                 | map     | Groovy Map containing sample information e.g. `[ id:pair_id ]` |                   |
| snp\_pileup          | file    | The pileup file                                                | \*.snp\_pileup.gz |
| legacy\_output\_mode | boolean | Flag to run Facets in legacy output mode                       |                   |

## Outputs

| Output            | Type | Description                                                                               | Pattern             |
| ----------------- | ---- | ----------------------------------------------------------------------------------------- | ------------------- |
| purity\_seg       | file | The purity seg file                                                                       | \*\_purity.seg      |
| purity\_rdata     | file | The purity R data file. This could be an .Rdata (legacy output) or .rds (original output) | _\_purity.?d_       |
| purity\_png       | file | The purity png file. In legacy output the file would match \*.CNCF.png                    | _\_purity_png       |
| purity\_out       | file | The purity out file. Only in legacy output mode.                                          | \*\_purity.out      |
| purity\_cncf\_txt | file | The purity cncf file. Only in legacy output mode.                                         | \*\_purity.cncf.txt |
| hisens\_seg       | file | The hisens seg file                                                                       | \*\_hisens.seg      |
| hisens\_rdata     | file | The hisens R data file. This could be an .Rdata (legacy output) or .rds (original output) | _\_hisens.?d_       |
| hisens\_png       | file | The hisens png file. In legacy output the file would match \*.CNCF.png                    | _\_hisens_png       |
| hisens\_out       | file | The hisense out file. Only in legacy output mode.                                         | \*\_hisens.out      |
| hisens\_cncf\_txt | file | The hisens cncf file. Only in legacy output mode.                                         | \*\_hisens.cncf.txt |
| qc\_txt           | file | The qc file                                                                               | \*.qc.txt           |
| gene\_level\_txt  | file | The gene level file                                                                       | \*.gene\_level.txt  |
| arm\_level\_txt   | file | The arm level file                                                                        | \*.arm\_level.txt   |
| output\_txt       | file | The facets output log file. Format \[id].txt                                              | \*.txt              |
| versions          | file | File containing software versions                                                         | versions.yml        |

## Authors

@nikhil

## Maintainers

@nikhil
