# Overview

### Introduction

The [mskcc-omics-workflows/modules](https://github.com/mskcc-omics-workflows/modules) repository provides assistance in sharing and implementing components for development of nf-core pipelines at MSKCC. It is an extension of the [nf-core/modules](https://github.com/nf-core/modules) repository. It maintains compatibility with nf-core, but allows the MSKCC community to maintain and custom tailor components to our developer community needs. Please read nf-core's [Getting started](https://nf-co.re/docs/usage/introduction) to familiarize yourself with the concept behind nf-core and nextflow.

If you would like to contribute a component to the mskcc-omics-workflows/modules repository, please refer to our documentation on [Contributing](contributing.md).

If you are developing a pipeline, please see the documentation on our available [Modules](broken-reference) and [Subworkflows](broken-reference), and refer to our documentation for [Pipeline Development](pipeline-development.md).

### Software Requirements

You will need the following software dependancies to contribute a component the mskcc-omics-workflows repository or create a nf-core pipeline:

* [nextflow](https://www.nextflow.io/docs/latest/install.html)
* [nf-test](https://www.nf-test.com/)
* [nf-core](https://github.com/nf-core/tools/)
* [Docker](https://docs.docker.com/engine/installation/) or [Singularity](https://www.sylabs.io/guides/3.0/user-guide/) this likely depends on if you're testing on you local machine or HPC.
