# Rules

### Versioning

1. Image versions should be matched with the bioinformatics tool versions they contain. Each version of one bioinformationcs tool should have only one version of image
2. For self-built image (python/R scripts, for example), start versioning from 0.1.0
   1. Patch release: 0.1.0 -> 0.1.1
   2. Minor release: 0.1.0 -> 0.2.0
   3. Major release: 0.1.0 -> 1.1.0&#x20;

### Dockerfile

1. Base image should be as light as possible
2. Avoid using "latest" tag (to avoid discrepancy from new tags)
3. Images should be tested with Nextflow modules BEFORE pushing to JFrog
