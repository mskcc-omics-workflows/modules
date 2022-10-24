# Workflow mangement

### Step to work on workflow repo

#### Set up environment

1.  Install poetry and git flow to local: (or use pip)

    ```
    brew install poetry
    brew install git-flow
    ```
2.  Clone the develop branch of tools repo to local (RECOMMEND to use personal access token to clone the repo, ref: [https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)):

    {% code overflow="wrap" %}
    ```
    git clone -b develop https://github.com/mskcc-omics-workflows/IMPACT-pipeline.git
    With token:
    git clone -b develop https://<username>:<personal_access_token>@github.com/mskcc-omics-workflows/IMPACT-pipeline.git
    ```
    {% endcode %}
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

#### Check existing modules in msk-tools repo or nf-core/modules

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

1.  Install a module from tools repo using the following command. You will be able to find your module in <mark style="color:blue;">`modules/msk-tools/`</mark> directory

    ```
    nf-core modules install <module_name>
    ```
2.  Install a module from nf-core/modules directly using the following command. You will find this module in <mark style="color:blue;">`modules/nf-core/`</mark> directory

    {% code overflow="wrap" %}
    ```
    nf-core modules --git-remote git@github.com:nf-core/modules.git install <module_name>
    ```
    {% endcode %}

#### Write a subworkflow

1. In `subworkflows` folder, add a new folder for your subworkflow. And create a new nextflow script with the name for your subworkflow
2. Import all modules you need for this subworflow
3. Create inputs, channels, and calls to modules, and the outputs
4. In `tests` folder under `subworkflows`, add a nf script with the name starting with <mark style="color:blue;">`test_`</mark> for testing your subworkflow. And add any necessary inputs in `nextflow.config` in this folder.
5.  <mark style="color:red;">To run tests, change your $PWD to subworkflows/\<your-subworkflow-name>!!</mark> And use this command below:&#x20;

    ```
    nextflow run tests/test_<your-subworkflow>.nf -profile docker
    ```
6. Note: To test subworkflow, please DO NOT use dummy parameters or inputs. All inputs should come in nextflow.config file. No hard-coded lines.&#x20;

#### Write a workflow

1. Similar to writing a subworkflow, except in `workflows` folder
2. Workflow name should start with <mark style="color:blue;">"run\_"</mark>, followed by your workflow name
3. The inputs of workflow should be as simple as possible, for example, a folder. All the intermediate inputs for subworkflows/modules need to be processed in workflow/supportive scripts.
4.  <mark style="color:red;">To run test for workflows, change your $PWD to the root of the directory!! And call your workflows in</mark> <mark style="color:red;"></mark><mark style="color:red;">`main.nf`</mark> <mark style="color:red;"></mark><mark style="color:red;">script with proper params in nextflow.config .</mark>

    And use this command below:&#x20;

    ```
    nextflow run main.nf -profile docker And all required inputs
    ```
5. Each workflow should have one supportive groovy scripts in `lib` with it. This script is used to define/validate the inputs of the workflow, as well as to do post-processing of a workflow
6. If there is a supportive script in python, R, java, or perl, please add them in `bin` folder

#### Notes

* Creating new module is also available in the workflow level. This is more for workflow-specific modules that do not need to add to tools repo.
