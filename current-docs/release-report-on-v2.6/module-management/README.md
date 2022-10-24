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
2.  Clone the develop branch of tools repo to local (RECOMMEND to use personal access token to clone the repo, ref: [https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)):

    {% code overflow="wrap" %}
    ```
    git clone -b develop https://github.com/mskcc-omics-workflows/tools.git
    With token:
    git clone -b develop https://<username>:<personal_access_token>@github.com/mskcc-omics-workflows/tools.git
    ```
    {% endcode %}
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

    {% code overflow="wrap" %}
    ```
    nf-core modules create <Module_Name> --author @<your_github_username> --label process_low --meta 
    ```
    {% endcode %}
* Note:
  * If the module is a subtool, please use, for example, `samtools/sort` for the module name
  * You will be able to find your module in <mark style="color:blue;">modules/msk-tools</mark> directory, and tests in <mark style="color:blue;">tests/modules/msk-tools/\<your\_module\_name></mark>
  * Module name can contain "\_" but not "-"

#### Add small-sized test datasets

1. Make a new folder for test datasets for the module in [https://github.mskcc.org/MSKCC-Omics-Workflows/tools-test-dataset.git](https://github.mskcc.org/MSKCC-Omics-Workflows/tools-test-dataset.git). This repo is a submodule of the main tools repo
2. NOTES: If the size of the test dataset is larger than 100MB, please follow the instruction of "Test dataset management" page to store the file in a docker image
3.  In your feature branch, do the following and pull the latest changes

    ```
    git submodule update --init --recursive
    ```

#### To run test or check the format of the module

*   To run test locally

    ```
    nf-core modules test <your_module_name>
    ```

    * In <mark style="color:blue;">nextflow.config</mark> of the test in <mark style="color:blue;">tests/modules/msk-tools/\<your\_module\_name></mark>, the path of the container has to be added, with the correct version of the tool
*   To check if the format is matching with nf-core:&#x20;

    ```
    nf-core modules lint <your_module_name>
    ```
*   To run test on HPC

    ```
    nf-core modules test <your_module_name> --hpc
    ```
* <mark style="color:red;">NOTES: A potential issue might happen when running the test: "profile" value is not able to parse to the testing itself. Either choosing from the provided list of "docker", "singularity", and "conda", or setting up the env var</mark> <mark style="color:red;"></mark><mark style="color:red;">`$PROFILE`</mark> <mark style="color:red;"></mark><mark style="color:red;">manually, the testing is still not be able to get that. In this case, please add</mark> <mark style="color:red;"></mark><mark style="color:red;">`-profile <your_profile>`</mark> <mark style="color:red;"></mark><mark style="color:red;">in the testing command in</mark> <mark style="color:red;"></mark><mark style="color:red;">`test.yml`</mark> <mark style="color:red;"></mark><mark style="color:red;">of the module, it will work fine.</mark>&#x20;

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

      {% code overflow="wrap" %}
      ```shell
      $ echo $CR_PAT | docker login ghcr.io -u <your_github_username> --password-stdin
      > Login Succeeded
      ```
      {% endcode %}
*   To create docker image, modify the <mark style="color:blue;">Dockerfile</mark> first, and change $PWD to <mark style="color:blue;">modules/msk-tools/\<your\_module\_name>/container</mark>, and run:

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
