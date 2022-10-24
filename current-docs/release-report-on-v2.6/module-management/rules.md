# Rules

#### Version control

* Version control of the bioinformatics tools will be tracked via containers. In the nextflow.config file, we can specify the containers that we need to run tools, regardless of the containers written inside of the modules. That way we can run the same modules with different versions of containers.
* Reference: [https://www.nextflow.io/docs/latest/container.html](https://www.nextflow.io/docs/latest/container.html)

#### Modify main module script

*   Tool version is tracked through the following line from the template. The second half of the code below is to delete all text when you do `--version` to the tool, so the word <mark style="color:blue;">`Using`</mark> needs to be changed based on the text from the tool.

    {% code overflow="wrap" %}
    ```
    {{ tool }}: $(echo $(samtools --version 2>&1) | sed 's/^.samtools //; s/Using.$//' )
    ```
    {% endcode %}
* Optional inputs can be achieved in the main script, example is here: [https://github.com/nextflow-io/patterns/blob/master/docs/optional-input.adoc](https://github.com/nextflow-io/patterns/blob/master/docs/optional-input.adoc)
* After adding Dockerfile and README.md (see the tutorial), please move <mark style="color:blue;">README.md</mark> to the module root directory, ie,&#x20;
  * From <mark style="color:blue;">modules/msk-tools/\<your\_module\_name>/container</mark>
  * To <mark style="color:blue;">modules/msk-tools/\<your\_module\_name>.</mark>&#x20;
  * README.md should contain:&#x20;
    * Module\_name
    * Description
    * Usage (Inputs and Outputs)
    * Reference (full command of the tool, or any other information)
*   In the <mark style="color:blue;">meta.yml</mark> file, if there is meta map object, please add comment about all the allowed key and value pairs in meta object. For example, for bcl2fastq, &#x20;

    {% code overflow="wrap" %}
    ```
     Groovy Map containing sample information
     e.g. [ id:'test', run:'220726_M0720', pool: 'test', mismatch: '1', base_mask: '', no_lane_split: '', ignore_map: [:]]
    ```
    {% endcode %}

#### Write unit test

*   Profiles to add for process tools in the config file above

    <pre><code><strong>profiles {
    </strong>    debug { process.beforeScript = 'echo $HOSTNAME' }
        conda {
            params.enable_conda    = true
            docker.enabled         = false
            singularity.enabled    = false
            podman.enabled         = false
            shifter.enabled        = false
            charliecloud.enabled   = false
        }
        docker {
            docker.enabled         = true
            docker.userEmulation   = true
            singularity.enabled    = false
            podman.enabled         = false
            shifter.enabled        = false
            charliecloud.enabled   = false
        }
        singularity {
            singularity.enabled    = true
            singularity.autoMounts = true
            docker.enabled         = false
            podman.enabled         = false
            shifter.enabled        = false
            charliecloud.enabled   = false
        }
        podman {
            podman.enabled         = true
            docker.enabled         = false
            singularity.enabled    = false
            shifter.enabled        = false
            charliecloud.enabled   = false
        }
        shifter {
            shifter.enabled        = true
            docker.enabled         = false
            singularity.enabled    = false
            podman.enabled         = false
            charliecloud.enabled   = false
        }
        charliecloud {
            charliecloud.enabled   = true
            docker.enabled         = false
            singularity.enabled    = false
            podman.enabled         = false
            shifter.enabled        = false
        }
    }</code></pre>
* Test datasets/files provided to the module can be added in the config file above, with FULL PATHs. You can also use `Channel` in nextflow to load input files. When loading to `Channel`, the file path can be relative, BUT it must be accessible in `$PWD` where you are running unit test.
* There is an additional testing added to <mark style="color:blue;">test.yml.</mark> This is for testing on HPC, with the name and tags starting with <mark style="color:blue;">`"hpc_"`</mark>. Please DO NOT delete this key words, otherwise it will error out during the testing. This is only available for new modules.
* In <mark style="color:blue;">test.yml</mark> file,  you can include md5sum to the output file. It will change frequently due to a different location of output file, or changing the inputs of the test. So I recommend not to check md5sum at the beginning of your test. We can include them in the final version of the module, right before the release. <mark style="color:red;"></mark>&#x20;
*   When doing the test, after choosing in "Docker", "Singularity", and "Conda", if the container is still not found, please add the following argument in `tests/modules/msk-tools/<your_module_name>/test.yml` and restart your testing:

    ```
    -profile docker
    ```

#### Unit testing on LSF

*   Running on HPC requires some changes in the nextflow config file.&#x20;

    Reference can be found here: [https://www.nextflow.io/docs/latest/executor.html](https://www.nextflow.io/docs/latest/executor.html) and [https://www.nextflow.io/blog/2021/5\_tips\_for\_hpc\_users.html](https://www.nextflow.io/blog/2021/5\_tips\_for\_hpc\_users.html).&#x20;
*   The config added to the root directory of tools.git, has been renamed as "hpc\_test.config".

    It has the following section:

    ```
    executor {
        name = 'lsf'
        queueSize = 20
        submitRateLimit = '10/2min'
    }
    ```
*   Create conda using:&#x20;

    ```
    conda env create -f nextflow_env.yml
    ```
*   Set up singularity authentication before running the test. This is for bypassing the auth from github:&#x20;

    ```
    export SINGULARITY_DOCKER_USERNAME=<github_user_name>
    export SINGULARITY_DOCKER_PASSWORD=<personal_access_token>
    ```
*   On Juno, load singularity:

    ```textile
    module load singularity/3.7.1
    ```
*   Use `-profile singularity` on Juno when running the test

    ```textile
    nf-core modules test <your_module_name> --hpc
    ```

    It will look for sections in <mark style="color:blue;">test.yml</mark> starting with <mark style="color:blue;">`"hpc_"`</mark> in the names and tags, and run the test. Please note that checking for "md5sum" is not available in this version.&#x20;
*   When doing the test, after choosing in "Docker", "Singularity", and "Conda", if the container is still not found, please add the following argument to the command in <mark style="color:blue;">test.yml</mark> file and restart your testing:

    ```
    -profile docker # Or singularity or conda
    ```

#### If a module is already in nf-core/modules, there is no need to create our own. But we need a container for the module

* Need unit testing with our own customized config???
* `nf-core modules --git-remote git@github.com:nf-core/modules.git add cutadapt?`
* To be discussed...

#### Need to download a module for nf-core/modules as a template for our own customized usage?&#x20;

* &#x20;Well, we will need to copy and paste from nf-core/modules.

