# Workflow Management

### Step to work on workflow repo

#### Set up environment

1.  Install poetry and git flow to local: (or use pip)

    ```
    brew install poetry
    brew install git-flow
    ```
2.  Clone the develop branch of tools repo to local:

    ```
    git clone hhttps://github.com/mskcc-omics-workflows/IMPACT-pipeline.git
    ```
3.  change directory to the downloaded repo:

    ```
    cd impact-pipeline
    ```
4.  Create new feature branch

    ```
    git flow init
    git flow feature start <your-workflow-name>
    ```
5.  Install all dependencies

    ```
    poetry install
    ```
6.  Activate virtual environment

    ```
    poetry shell
    ```

#### Check existing modules in tools repo or nf-core/modules

1.  To list all available modules in tools repo

    ```
    nf-core modules list remote
    nf-core modules --git-remote git@github.com:nf-core/modules.git list remote
    ```
2.  To check information of a particular tool

    ```
    nf-core modules info <module_name>
    nf-core modules --git-remote git@github.com:nf-core/modules.git info <module_name>
    ```
3.  All nf-core modules commands are available

    ```
    ╭─ For pipelines ──────────────────────────────────────────────────────────────────────────────────╮
    │ list          List modules in a local pipeline or remote repository.                             │
    │ info          Show developer usage information about a given module.                             │
    │ install       Install DSL2 modules within a pipeline.                                            │
    │ update        Update DSL2 modules within a pipeline.                                             │
    │ remove        Remove a module from a pipeline.                                                   │
    │ patch         Create a patch file for minor changes in a module                                  │
    ╰──────────────────────────────────────────────────────────────────────────────────────────────────╯
    ```

#### Install a module from tools repo or nf-core/modules

1.  Install a module from tools repo using the following command. You will be able to find your module in `modules/mskcc-omics-workflows/tools/` directory

    ```
    nf-core modules install <module_name>
    ```
2.  Install a module from nf-core/modules directly using the following command. You will find this module in `modules/nf-core/modules/` directory

    ```
    nf-core modules --git-remote git@github.com:nf-core/modules.git install <module_name>
    ```

#### Notes

* Creating new module is also available in the workflow level. This is more for workflow-specific modules that do not need to add to tools repo.
