# Module Management

#### Reference

{% embed url="https://nf-co.re/developers/modules" %}

### Step to create a new module

#### Set up environment

1.  Install poetry and git flow to local: (or use pip)

    ```
    brew install poetry
    brew install git-flow
    ```
2.  Clone the develop branch of tools repo to local:

    ```
    git clone https://github.com/mskcc-omics-workflows/tools.git
    ```
3.  change directory to the downloaded repo:

    ```
    cd tools
    ```
4.  Create new feature branch

    ```
    git flow init
    git flow feature start <your-module-name>
    ```
5.  Install all dependencies

    ```
    poetry install
    ```
6.  Activate virtual environment

    ```
    poetry shell
    ```

#### Create a module with test files

*   To create a new module, use the nf-core command directly

    ```
    nf-core modules create <Module_Name> --author @<your_github_username> --label process_low --meta 
    ```
* Note:
  * If the module is a subtool, please use, for example, `samtools/sort` for the module name
  * You will be able to find your module in <mark style="color:blue;">modules/</mark> directory, and tests in <mark style="color:blue;">tests/modules/\<your\_module\_name></mark>
  * Module name can contain "\_" but not "-"

#### Add small-sized test datasets

1. Make a new folder for test datasets for the module in [https://github.com/mskcc-omics-workflows/tools-test-dataset.git](https://github.com/mskcc-omics-workflows/tools-test-dataset.git). This repo is a submodule of the main tools repo
2.  In your feature branch, do the following and pull the latest changes

    ```
    git submodule update --init --recursive
    ```

#### To run test or check the format of the module

*   To run test

    ```
    nf-core modules test <your_module_name>
    ```

    * In <mark style="color:blue;">nextflow.config</mark> of the test in <mark style="color:blue;">tests/modules/\<your\_module\_name></mark>, the path of the container has to be added, with the correct version of the tool
*   To check if the format is matching with nf-core:&#x20;

    ```
    nf-core modules lint <your_module_name> --dir .
    ```
*   To run test on HPC (ONLY available when you install nf-core v2.5.1.2, and create new modules with nf-core v2.5.1.2)

    ```
    nf-core modules test <your_module_name> --hpc
    ```

#### Document and Dockerfile

*   For us only to add Dockerfile and README.md

    ```
    make dockerfile
    ```

    * It requires to provide an existing module. The two files will be in <mark style="color:blue;">modules/\<your\_module\_name>/container</mark>
* In order to push images to github package, we need to create a new personal access token (PAT) with the appropriate scopes for the tasks you want to accomplish.
  * Select the `read:packages` scope to download container images and read their metadata.
  * Select the `write:packages` scope to download and upload container images and read and write their metadata.
  * Select the `delete:packages` scope to delete container images.
* After creating your personal token:
  *   Save your PAT. We recommend saving your PAT as an environment variable.

      ```shell
      $ export CR_PAT=<<YOUR_TOKEN>
      ```
  *   Using the CLI for your container type, sign in to the Container registry service at `ghcr.io`.

      ```shell
      $ echo $CR_PAT | docker login ghcr.io -u <your_github_username> --password-stdin
      > Login Succeeded
      ```
*   To create docker image, modify the <mark style="color:blue;">Dockerfile</mark> first, and change $PWD to <mark style="color:blue;">modules/\<your\_module\_name>/container</mark>, and run:

    ```
    docker build . -t ghcr.io/mskcc-omics-workflows/<YOUR_MODULE_NAME>:<VERSION>
    docker push ghcr.io/mskcc-omics-workflows/<YOUR_MODULE_NAME>:<VERSION>
    ```

#### Check current modules

*   To list all available modules in tools repo

    ```
    nf-core modules list remote
    ```
*   To check information of a particular tool

    ```
    nf-core modules info <module_name>
    ```
*   All nf-core modules commands are available

    ```
    ╭─ Developing new modules ─────────────────────────────────────────────────────────────────────────╮
    │ create            Create a new DSL2 module from the nf-core template.                            │
    │ create-test-yml   Auto-generate a test.yml file for a new module.                                │
    │ lint              Lint one or more modules in a directory.                                       │
    │ bump-versions     Bump versions for one or more modules in a clone of the nf-core/modules repo.  │
    │ mulled            Generate the name of a BioContainers mulled image version 2.                   │
    │ test              Run module tests locally.                                                      │                                        │
    ╰──────────────────────────────────────────────────────────────────────────────────────────────────╯
    ```
