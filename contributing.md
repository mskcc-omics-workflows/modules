# Contributing

### Contributing

To contribute new and updated existing [modules](https://nf-co.re/docs/contributing/modules) and [subworkflows](https://nf-co.re/docs/contributing/subworkflows) the mskcc-omics-workflows repository, please perform all development in a fork of the repository and open a pull request to merge changes into the master branch of the upstream repository.

Please follow nf-core's guides for contributing [modules](https://nf-co.re/docs/contributing/modules) and [subworkflows](https://nf-co.re/docs/contributing/subworkflows), but with two major differences:

1. Set the upstream repository of your development fork to https://github.com/mskcc-omics-workflows/modules
2. When you are satisfied with your changes, open a pull request to the upstream repository, not the nf-core/modules repository

Additional recommendations for mskcc-omics-workflows are detailed below.

### Module development

Refer to nf-core's guide on [creating new modules](https://nf-co.re/docs/contributing/modules).

#### Testing Using nf-core/tools

When testing a module using `nf-core modules test` in the mskcc-omics-workflows/modules repo, the `--git-remote` argument and `-b` arguments must be used:

{% code overflow="wrap" %}
```
nf-core modules test --git-remote https://github.com/mskcc-omics-workflows/modules.git -b <module_branch> test <tool> 
```
{% endcode %}

This is due to a quirk in nf-core/tools in which the org\_path (msk in this case) is pulled from the remote github instead of using the local .nf-core.yml. Note that your module branch must be pushed to remote for this to work. \
\
If you experience trouble using nf-test through nf-core/tools, you can always use nf-test directly:&#x20;

```
nf-test test --profile=docker --tag <module_tag>
```

That being said, testing through nf-core/tools is preferable as it checks snapshot stability by running nf-test twice and comparing snapshots for equality.&#x20;

#### Testing Using Stubs

All modules in mskcc-omics-workflows/modules should have a [`stub`](https://www.nextflow.io/docs/latest/process.html#stub) block to facilitate easier testing. This is not required in nf-core/modules repository or for nf-core/tools compatibility, but this feature makes it easier to quickly prototype workflow logic without using the real commands.

### Subworkflow development

Refer to nf-core's guide on [creating new subworkflows](https://nf-co.re/tools#create-a-new-subworkflow).

#### Configuration

Creating a custom configuration file for a subworkflow in a Nextflow pipeline is a good practice for including useful settings without changing process definitions of the module. That way a module can be reused in multiple workflows, but its implementation changes in the context of a subworkflow. Here are the steps to create and use a custom configuration file for a subworkflow:

1. Create a `nextflow.config` file in the directory where your subworkflow file is located.
2.  In the `nextflow.config` file, you can specify configurations specific to your subworkflow. These configurations can include command-line arguments, input data paths, output paths, and any other settings relevant to your subworkflow. Below is an example of what a nextflow.config file might look like:

    ```
    process {

        withName: '.*:SUBWORKFLOW1:MODULE1' {
            ext.args = '-a 10 -b 70'
        }

        withName: '.*:SUBWORKFLOW1:MODULE2' {
            ext.args = "--dedup"
        }

    }
    ```
3. Include this configuration file in the configuration for each testing workflow. In the `nextflow.config` file in the directory where your subworkflow test files are located, use Nextflow's `includeConfig` keyword to add the subworkflow configuration to the test workflow initialization.

### Test data

Testing workflows for modules and subworkflows should make use of test-data that is very small (aggressively sub-sampled) and reused from a centralized location whenever possible. Refer to nf-core's guide on using their [existing test data](https://nf-co.re/docs/contributing/test\_data\_guidelines). An alternative source of data specific to MSKCC is currently under development.

### When to contribute to mskcc-omics-workflows

Although developers at MSKCC can contribute to either the publicly available nf-core/modules repository or the insitutional mskcc-omics-workflows/modules repository, there are cases in which the latter are more favorable. Developers are encouraged to contribute to our institutional modules repository under the following circumstances:

1. **Code/Packages that are private to MSKCC:**\
   If the software is intended solely for internal use within our organization, it should be housed in mskcc-omics-workflows/modules
2. **Subworkflows:**\
   Any subworkflow with institution-specific configurations should be housed in mskcc-omics-workflows/modules.
3. **Modules Intended For Use in Subworkflows:**\
   Currently, subworkflows in mskcc-omics-workflows/modules can only include modules and subworkflows from the same repository. Therefore, even if the module already exists in nf-core/modules, it may be necessary to replicate it in our institutional repo to make it accessible to other subworkflows.



###
