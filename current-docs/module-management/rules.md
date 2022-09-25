# Rules

#### Version control

* Version control of the bioinformatics tools will be tracked via containers. In the nextflow.config file, we can specify the containers that we need to run tools, regardless of the containers written inside of the modules. That way we can run the same modules with different versions of containers.
* Reference: [https://www.nextflow.io/docs/latest/container.html](https://www.nextflow.io/docs/latest/container.html)

#### Modify main module script

*   In the <mark style="color:blue;">main.nf</mark> script, in the `versions` generation in the script section, there is a typo in nf-core template. There should be just one `)` at the end of the line below. Otherwise, you will see an additional `)` at the end of the version in your output `versions.yml`

    ```
    {{ tool }}: $(echo $(samtools --version 2>&1) | sed 's/^.samtools //; s/Using.$//' )
    ```
* The second half of the code above is to delete all text when you do `--version` to the tool, so the `Using` word needs to be changed based on the text from the tool.
* Optional inputs can be achieved in the main script, example is here: [https://github.com/nextflow-io/patterns/blob/master/docs/optional-input.adoc](https://github.com/nextflow-io/patterns/blob/master/docs/optional-input.adoc)
* After adding Dockerfile and README.md (see the tutorial), please move <mark style="color:blue;">README.md</mark> to the module root directory, ie, from <mark style="color:blue;">modules/\<your\_module\_name>/container to modules/\<your\_module\_name>.</mark> README.md should contain:&#x20;
  * Module\_name
  * Description
  * Usage (Inputs and Outputs)
  * Reference (full command of the tool, or any other information)
*   In the <mark style="color:blue;">meta.yml</mark> file, if there is meta map object, please add comment about all the allowed key and value pairs in meta object. For example, for bcl2fastq, &#x20;

    ```
     Groovy Map containing sample information
     e.g. [ id:'test', run:'220726_M0720', pool: 'test', mismatch: '1', base_mask: '', no_lane_split: '', ignore_map: [:]]
    ```

#### Write unit test

*   If your module name contains underline "\_", in <mark style="color:blue;">tests/modules/\<your\_module\_name>/nextflow.config</mark>, change&#x20;

    ```
    publishDir = { "${params.outdir}/${task.process.tokenize(':')[-1].tokenize('_')[0].toLowerCase()}" }
    ```

    To:

    ```
    publishDir = { "${params.outdir}/${task.process.tokenize(':')[-1].toLowerCase()}" }
    ```
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
* In <mark style="color:blue;">test.yml</mark> file,  you can include md5sum to the output file. It will change frequently due to a different location of output file, or changing the inputs of the test. So I recommend not to check md5sum at the beginning of your test. We can include them in the final version of the module, right before the release.

#### Unit testing on LSF

1.  Running on HPC requires some changes in the nextflow config file.&#x20;

    Reference can be found here: [https://www.nextflow.io/docs/latest/executor.html](https://www.nextflow.io/docs/latest/executor.html) and [https://www.nextflow.io/blog/2021/5\_tips\_for\_hpc\_users.html](https://www.nextflow.io/blog/2021/5\_tips\_for\_hpc\_users.html). In order to avoid confusion with the local unit testing, I recommend to add a new config file named <mark style="color:blue;">`lsf_test.config`</mark> in <mark style="color:blue;">tests/modules/\<your\_module\_name></mark> repo with the following section:

    ```
    executor {
        name = 'lsf'
        queueSize = 20
        submitRateLimit = '10/2min'
    }
    ```
2.  Create conda using:&#x20;

    ```
    conda env create -f nextflow_env.yml
    ```
3.  Set up singularity authentication before running the test. This is for bypassing the auth from github:&#x20;

    ```
    export SINGULARITY_DOCKER_USERNAME=<github_user_name>
    export SINGULARITY_DOCKER_PASSWORD=<persional_access_token>
    ```
4.  Use `-profile singularity` on Juno when running the test. I used `singularity/3.7.1` and it is working. For example:

    ```
    nextflow run ./tests/modules/pre_bcl2fastq -entry test_pre_bcl2fastq -c ./tests/config/nextflow.config -c ./tests/modules/pre_bcl2fastq/lsf_test.config -profile singularity
    ```

#### If a module is already in nf-core/modules, there is no need to create our own. But we need a container for the module

* Need unit testing with our own customized config???
* `nf-core modules --git-remote git@github.com:nf-core/modules.git add cutadapt?`
* To be discussed...

#### Need to download a module for nf-core/modules as a template for our own customized usage?&#x20;

* &#x20;Well, we will need to copy and paste from nf-core/modules.



#### Module testing on HPC

* To be developed...
