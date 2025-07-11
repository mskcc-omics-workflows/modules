# Contributing

In the following sections, we will go over the specifics of how to contribute a module or sub-workflow to mskcc-omics-workflows. While not required, it will likely be helpful for the user to understand how our contributing guidelines mirror nf-core's, therefore we recommend reading [writing nf-core components](https://nf-co.re/docs/tutorials/nf-core_components/components) while following along with this tutorial.&#x20;

## Software Requirements

You will need the following software dependancies to contribute a component the mskcc-omics-workflows repository:

* [nextflow](https://www.nextflow.io/docs/latest/install.html)
* [nf-test](https://www.nf-test.com/)
* [nf-core](https://github.com/nf-core/tools/)
* [Docker](https://docs.docker.com/engine/installation/) or [Singularity](https://www.sylabs.io/guides/3.0/user-guide/) this likely depends on if you're testing on you local machine or HPC.

## Component development

### Getting Started&#x20;

To contribute new and updated existing [modules](https://nf-co.re/docs/contributing/modules) to the mskcc-omics-workflows repository, please perform all development in a fork of the repository and open a pull request to merge changes into the `development` branch of the upstream repository\
\
You can do this with by [forking and cloning](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/fork-a-repo) the [mskcc-omics-workflows repository](https://github.com/mskcc-omics-workflows/modules/tree/develop). \
\
Then running:&#x20;

```
cd modules
git remote add upstream https://github.com/mskcc-omics-workflows/modules.git
git checkout -b <module/subworkflow>
```

### Creating a component

Create the component using:

{% tabs %}
{% tab title="module" %}
{% code overflow="wrap" %}
```
nf-core modules --git-remote https://github.com/mskcc-omics-workflows/modules.git -b <module_branch> create <module> 
```
{% endcode %}
{% endtab %}

{% tab title="subworkflow" %}
{% code overflow="wrap" %}
```
nf-core subworkflows --git-remote https://github.com/mskcc-omics-workflows/modules.git -b <subworkflow_branch> create <subworkflow> 
```
{% endcode %}
{% endtab %}
{% endtabs %}

It is important to note here that we need to specify the `--git-remote` and `-b` option when using any `nf-core` commands. This is because by default these parameters point to [nf-core modules](https://github.com/nf-core/modules) and it's master branch.

After creating the component, there are 3 files to modify:

{% tabs %}
{% tab title="module" %}
1.  [`./modules/msk/facets/main.nf`](https://github.com/mskcc-omics-workflows/modules/blob/develop/modules/msk/facets/main.nf)

    This is the main script containing the `process` definition for the module. You will see an extensive number of `TODO` statements to help guide you to fill in the appropriate sections and to ensure that you adhere to the guidelines we have set for module submissions.
2.  [`./modules/msk/facets/meta.yml`](https://github.com/mskcc-omics-workflows/modules/blob/develop/modules/msk/facets/meta.yml)

    This file will be used to store general information about the module and author details - the majority of which will already be auto-filled. However, you will need to add a brief description of the files defined in the `input` and `output` section of the main script since these will be unique to each module. We check it’s formatting and validity based on a [JSON schema](https://github.com/nf-core/modules/blob/master/.yaml-schema.json) during linting (and in the pre-commit hook).
3.  [`./modules/msk/facets/tests/main.nf.test`](https://github.com/mskcc-omics-workflows/modules/blob/develop/modules/msk/facets/tests/main.nf.test)

    Every module must have a test workflow. This file will define one or more Nextflow `workflow` definitions that will be used to unit test the output files created by the module. By default, one `workflow` definition will be added.\
    \
    In addition, a [`stub`](https://www.nextflow.io/docs/latest/process.html#stub) test is also required. Stub test enable users to provide a dummy script that mimics the execution of the real one in a quicker manner. It is a way to perform a dry-run of a module without data. An example is found in the [facets module](https://github.com/mskcc-omics-workflows/modules/blob/develop/modules/msk/facets/tests/main.nf.test). \
    \
    Minimal test data required for your module may already exist within the [mskcc-omics-workflows/modules repository](https://github.com/mskcc-omics-workflows/modules/blob/develop/tests/config/test_data.config) - see the [Test data section](contributing.md#test-data) for more info. Minimal test data is required unless the module cannot be run using a very small data set. In which case, a `stub` test may be accepted as a  workflows only test \
    \
    Refer to the section [writing nf-test tests](https://nf-co.re/docs/tutorials/tests_and_test_data/nf-test_writing_tests) for more information on how to write nf-tests.&#x20;
{% endtab %}

{% tab title="subworkflow" %}


*   [`./subworkflow/msk/neoantigen_editing/main.nf`](https://github.com/mskcc-omics-workflows/modules/blob/develop/subworkflows/msk/neoantigen_editing/main.nf)

    This is the main script containing the `workflow` definition for the subworkflow. You will see an extensive number of `TODO` statements to help guide you to fill in the appropriate sections and to ensure that you adhere to the guidelines we have set for module submissions.
*   [`./subworkflow/msk/neoantigen_editing/meta.yml`](https://github.com/mskcc-omics-workflows/modules/blob/develop/subworkflows/msk/neoantigen_editing/meta.yml)

    This file will be used to store general information about the subworkflow and author details. You will need to add a brief description of the files defined in the `input` and `output` section of the main script since these will be unique to each subworkflow.
*   [`./subworkflow/msk/neoantigen_editing/tests/main.nf.test`](https://github.com/mskcc-omics-workflows/modules/blob/develop/subworkflows/msk/neoantigen_editing/tests/main.nf.test)

    Every subworkflow must have a test workflow. This file will define one or more Nextflow `workflow` definitions that will be used to unit test the output files created by the subworkflow. By default, one `workflow` definition will be added.\
    \
    In addition, a [`stub`](https://www.nextflow.io/docs/latest/process.html#stub) test is also required. Stub test enable users to provide a dummy script that mimics the execution of the real one in a quicker manner. It is a way to perform a dry-run of a subworkflow without data. An example is found in the [neoantigen\_editing subworkflow](https://github.com/mskcc-omics-workflows/modules/blob/develop/subworkflows/msk/neoantigen_editing/tests/main.nf.test). Note that a stub test will only work for a subworkflow if every module in the subworkflow also has a stub test. This is why stub tests are required for all modules.\
    \
    Minimal test data required for your module may already exist within the [mskcc-omics-workflows/modules repository](https://github.com/mskcc-omics-workflows/modules/blob/develop/tests/config/test_data.config) - see the [Test data section](contributing.md#test-data) for more info. Minimal test data is required unless the module cannot be run using a very small data set. In which case, a `stub` test may be accepted as a  workflows only test \
    \
    Refer to the section [writing nf-test tests](https://nf-co.re/docs/tutorials/tests_and_test_data/nf-test_writing_tests) for more information on how to write nf-tests.&#x20;
{% endtab %}
{% endtabs %}

### Testing a component

Once the files are edited, the user can run their test with:&#x20;

{% tabs %}
{% tab title="module" %}
{% code overflow="wrap" %}
```
nf-core modules --git-remote https://github.com/mskcc-omics-workflows/modules.git -b <module_branch> test <module> 
```
{% endcode %}
{% endtab %}

{% tab title="subworkflow" %}
{% code overflow="wrap" %}
```
nf-core subworkflows --git-remote https://github.com/mskcc-omics-workflows/modules.git -b <subworkflow_branch> test <subworkflow> 
```
{% endcode %}
{% endtab %}
{% endtabs %}

and the stub-test with:&#x20;

{% tabs %}
{% tab title="module" %}
{% code overflow="wrap" %}
```
nf-core modules --git-remote https://github.com/mskcc-omics-workflows/modules.git -b <module_branch> test <module> -stub-run
```
{% endcode %}
{% endtab %}

{% tab title="subworkflow" %}
{% code overflow="wrap" %}
```
nf-core subworkflows --git-remote https://github.com/mskcc-omics-workflows/modules.git -b <subworkflow_branch> test <subworkflow> -stub-run
```
{% endcode %}
{% endtab %}
{% endtabs %}

#### Ignoring Conda Tests

While we encourage contributors to provide conda support for their modules, it is often not desirable or difficult to include.\
\
In this case, the `environment.yml` can be left un-changed. The module of interest should be added to the [exclude block](https://github.com/mskcc-omics-workflows/modules/blob/main/.github/workflows/test.yml#L349) in the `test.yml` gitaction. This tells the test git-action to skip the conda tests for the specified module.&#x20;

For example, a module named `example_module` can be skipped with the following:

```
      - profile: "conda"
        tags: example_module
```

### Linting a component

Once the files are edited, the user can run their lint with:&#x20;

{% code overflow="wrap" %}
```
nf-core modules --git-remote https://github.com/mskcc-omics-workflows/modules.git -b <module_branch> lint <module> 
```
{% endcode %}

{% tabs %}
{% tab title="module" %}
{% code overflow="wrap" %}
```
nf-core modules --git-remote https://github.com/mskcc-omics-workflows/modules.git -b <module_branch> lint <module> 
```
{% endcode %}
{% endtab %}

{% tab title="subworkflow" %}
{% code overflow="wrap" %}
```
nf-core subworkflows --git-remote https://github.com/mskcc-omics-workflows/modules.git -b <subworkflow_branch> lint <subworkflow> 
```
{% endcode %}
{% endtab %}
{% endtabs %}

Lint code checks that a module adheres to nf-core guidelines before submission.&#x20;

### Finishing Up

Once ready, you can push your changes to the fork with:

```
git pull --rebase upstream develop # pulls recent changes from upstream repo
git push -u origin # pushing changes
```

and create a pull request from your fork to the [upstream develop branch](https://github.com/mskcc-omics-workflows/modules/tree/develop). See [here](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request-from-a-fork) for more information.

### Review Process

The review process is done by an inter-team of reviewers that is automatically assigned to new Pull Requests. \
\
The current team is Nikhil Kumar, Anne Marie Noronha, Eric Buehler and Yu Hu.\
\
Basic criteria for a component being approved is all [github actions pass](https://github.com/mskcc-omics-workflows/modules/blob/main/.github/workflows/test.yml), which run workflow tests, linting and automated documentation.

It also may be advantageous to get approval from another reviewer who is invested in your module. For example, a developer from another team who may want to use the tools for a different use case.&#x20;

### Test data

Testing workflows for modules and subworkflows should make use of test-data that is very small (aggressively sub-sampled) and reused from a centralized location whenever possible. Refer to nf-core's guide on using their [existing test data](https://nf-co.re/docs/contributing/test_data_guidelines). An alternative source of data specific to MSKCC is currently available [here](https://github.com/mskcc-omics-workflows/test-datasets).

In-house test datasets should always be as small as possible. Master branch is not used to store any test data, instead, different types of branches will host corresponding data files. For example, [argos](https://github.com/mskcc-omics-workflows/test-datasets/tree/argos) contains test datasets for MSK Argos Pipeline, while [hg37](https://github.com/mskcc-omics-workflows/test-datasets/tree/hg37) branch is for hg37 related reference files.

* If there is a new test dataset fitting in existing branches, please make a PR to the corresponding branch.
* If test data files do not fit the existing branches, please create a new feature branch and once they are ready, contact our Reviewer team to do final review and create official branch.

For more description on how to contribute to the repository, please visit [README](https://github.com/mskcc-omics-workflows/test-datasets/blob/master/README.md).\
\
If the module cannot be run using a very small data set, then a [stub-run](https://www.nextflow.io/docs/edge/process.html#stub) must be used instead. A examples can be found in the [facets module](https://github.com/mskcc-omics-workflows/modules/blob/develop/modules/msk/facets/tests/main.nf.test) and the [neoantigen\_editing subworkflow](https://github.com/mskcc-omics-workflows/modules/blob/develop/subworkflows/msk/neoantigen_editing/tests/main.nf.test). Note that a stub test will only work for the subworkflow if every module in the subworkflow also has a stub test. This is why stub tests are required for all modules.

## When to contribute

MSK developers are encouraged to contribute to our mskcc-omics-workflows/modules instead of nf-core/modules under the following circumstances:

1. **Code/Packages that are private to MSKCC:**\
   If the software is intended solely for internal use within our organization, it should be housed in mskcc-omics-workflows/modules
2. **Subworkflows:**\
   Any subworkflow with institution-specific configurations should be housed in mskcc-omics-workflows/modules.
3. **Modules Intended For Use in Subworkflows:**\
   Currently, subworkflows in mskcc-omics-workflows/modules can only include modules and subworkflows from the same repository. Therefore, even if the module already exists in nf-core/modules, it may be necessary to replicate it in our institutional repo to make it accessible to other subworkflows.

* **Release.** The release cycle is on a rolling basis. You will see your module / subworkflow in main branch upon release, along with documentation from the `meta.yml` in this main page



