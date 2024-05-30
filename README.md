# mskcc-omics-workflows/modules

adapted from [nf-core/modules/README.md](https://github.com/nf-core/modules/blob/master/README.md)

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A521.10.3-23aa62.svg?labelColor=000000)](https://www.nextflow.io/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)

![GitHub Actions Coda Linting](https://github.com/nf-core/modules/workflows/Code%20Linting/badge.svg)

> THIS REPOSITORY IS UNDER ACTIVE DEVELOPMENT. SYNTAX, ORGANISATION AND LAYOUT MAY CHANGE WITHOUT NOTICE!

A repository for hosting [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) module files containing tool-specific process definitions and their associated documentation.

## Table of contents

- [mskcc-omics-workflows/modules](#mskcc-omics-workflowsmodules)
  - [Table of contents](#table-of-contents)
  - [Using existing modules](#using-existing-modules)
  - [Adding new modules](#adding-new-modules)
  - [Help](#help)
  - [Citation](#citation)

## Using existing modules

The module files hosted in this repository define a set of processes for software tools such as `facets`, `gbcms`, `snppileup` etc. This allows you to share and add common functionality across multiple pipelines in a modular fashion.

We use a helper command in the `nf-core/tools` package that uses the GitHub API to obtain the relevant information for the module files present in the [`modules/`](modules/) directory of this repository. This includes using `git` commit hashes to track changes for reproducibility purposes, and to download and install all of the relevant module files.

1. Install the latest version of [`nf-core/tools`](https://github.com/nf-core/tools#installation) (`>=2.0`)
2. List the available modules:

   ```console
   $ nf-core modules --git-remote git@github.com:mskcc-omics-workflows/modules.git list remote

                                         ,--./,-.
         ___     __   __   __   ___     /,-._.--~\
   |\ | |__  __ /  ` /  \ |__) |__         }  {
   | \| |       \__, \__/ |  \ |___     \`-._,-`-,
                                         `._,._,'

   nf-core/tools version 2.14.1 - https://nf-co.re

   INFO     Modules available from git@github.com:mskcc-omics-workflows/modules.git (main):

   ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
   ┃ Module Name                    ┃
   ┡━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┩
   │ custom/splitfastqbylane        │
   │ facets                         │
   │ gatk4/applybqsr                │
   │ gbcms                          │
   ..truncated..
   ```

3. Install the module in your pipeline directory:

   ```console
   $ nf-core modules --git-remote git@github.com:mskcc-omics-workflows/modules.git install facets

                                         ,--./,-.
         ___     __   __   __   ___     /,-._.--~\
   |\ | |__  __ /  ` /  \ |__) |__         }  {
   | \| |       \__, \__/ |  \ |___     \`-._,-`-,
                                         `._,._,'

    nf-core/tools version 2.14.1 - https://nf-co.re

    INFO     Installing 'facets'
    INFO     Use the following statement to include this module:

     include { FACETS } from '../modules/msk/facets/main'
   ```

4. Import the module in your Nextflow script:

   ```nextflow
   #!/usr/bin/env nextflow

   nextflow.enable.dsl = 2

   include { FACETS } from '../modules/msk/facets/main'
   ```

5. Remove the module from the pipeline repository if required:

   ```console
   $ nf-core modules --git-remote git@github.com:mskcc-omics-workflows/modules.git remove facets

                                         ,--./,-.
         ___     __   __   __   ___     /,-._.--~\
   |\ | |__  __ /  ` /  \ |__) |__         }  {
   | \| |       \__, \__/ |  \ |___     \`-._,-`-,
                                         `._,._,'

    nf-core/tools version 2.14.1 - https://nf-co.re

    INFO     Removed files for 'facets' and its dependencies 'facets'.
   ```

6. Check that a locally installed nf-core module is up-to-date compared to the one hosted in this repo:

   ```console
   $ nf-core modules --git-remote git@github.com:mskcc-omics-workflows/modules.git lint facets

                                         ,--./,-.
         ___     __   __   __   ___     /,-._.--~\
   |\ | |__  __ /  ` /  \ |__) |__         }  {
   | \| |       \__, \__/ |  \ |___     \`-._,-`-,
                                         `._,._,'

    nf-core/tools version 2.14.1 - https://nf-co.re

    INFO     Linting pipeline: '.'
    INFO     Linting module: 'facets'

    ╭─ [!] 6 Module Test Warnings ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
    │              ╷                             ╷                                                                                                                                          │
    │ Module name  │ File path                   │ Test message                                                                                                                             │
    │╶─────────────┼─────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╴│
    │ facets       │ modules/msk/facets/main.nf  │ Unable to connect to container registry, code:  403, url: <https://www.docker.com/mskcc/facets-suite:2.0.9>                                │
    │ facets       │ modules/msk/facets/main.nf  │ Container versions do not match                                                                                                          │
    │ facets       │ modules/msk/facets/meta.yml │ hisens_r_data  is present as an output in the main.nf, but missing in meta.yml                                                           │
    │ facets       │ modules/msk/facets/meta.yml │ purity_r_data  is present as an output in the main.nf, but missing in meta.yml                                                           │
    │ facets       │ modules/msk/facets/meta.yml │ hisens_rdata is present as an output in meta.yml but not in main.nf                                                                      │
    │ facets       │ modules/msk/facets/meta.yml │ purity_rdata is present as an output in meta.yml but not in main.nf                                                                      │
    │              ╵                             ╵                                                                                                                                          │
    ╰───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
    ╭───────────────────────╮
    │ LINT RESULTS SUMMARY  │
    ├───────────────────────┤
    │ [✔]  59 Tests Passed  │
    │ [!]   6 Test Warnings │
    │ [✗]   0 Tests Failed  │
   ```

## Adding new modules

If you wish to contribute a new module, please see the documentation on the [MSK Omics Workflow website](https://mskcc-omics-workflows.gitbook.io/omics-workflows/contributing).

> Please be kind to our code reviewers and submit one pull request per module :)

## Help

For further information or help, don't hesitate to get in touch on [Slack `#mskcc-omics-workflows` channel](https://mskcc.enterprise.slack.com/archives/C040T4MFCHJ).

## Citation

If you use the module files in this repository for your analysis please you can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
