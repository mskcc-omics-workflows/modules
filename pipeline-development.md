# Pipeline Development

### Pipeline Development

When developing a pipeline for the MSKCC community, we recommend hosting the pipeline repository in MSKCC github spaces. Please consider the [MSKCC Omics Workflows ](https://github.com/mskcc-omics-workflows/)organization for hosting your pipeline. Existing nf-core documentation is catered towards users who are developing pipelines for the broader nf-core user community, and below are the adaptation for the MSKCC community.

#### Creating a pipeline

To create a pipeline from scratch that follows nf-core standards, start by [creating a pipeline](https://nf-co.re/docs/contributing/adding\_pipelines#create-the-pipeline) and [pushing to github](https://nf-co.re/docs/contributing/adding\_pipelines#push-to-github). For example:

```
nf-core create mypipeline
## follow prompts 
cd msk/mypipeline
git remote add origin https://github.com/mskcc-omics-workflows/mypipeline.git
git push --all origin
```

> _**For mskcc-omics-workflows users:**_
>
> The pipeline will be generated with prefix. We suggest using the msk prefix when following the prompts

Three branches will populate automatically in your git repository:

* `master` - commits from stable releases only. Should always have code from the most recent release.
* `dev` - current development code. Merged into master for releases.
* `TEMPLATE` - used for syncing the pipeline template automation to the latest nf-core template. Should only contain commits with unmodified template code. You can periodically use nf-core's guide on [syncing your pipeline](https://nf-co.re/docs/contributing/sync).

> _**For mskcc-omics-workflows users:**_
>
> Pipelines hosted by nf-core are synced automatically to the nf-core template whenever there is an update to the template. Currently there is no proactive process in place for MSKCC pipelines, but developers can sync their pipelines periodically using `nf-core sync`.

#### Managing components

Once you have created the pipeline, you are ready to start adding functional components using the `nf-core modules` and `nf-core subworkflows` command families.

> _**For mskcc-omics-workflows users:**_
>
> Many commands and sub-commands in the nf-core/tools helper package must be configured to use components from our custom remote repository. This can be done using the `--git-remote git@github.com:mskcc-omics-workflows/modules.git` option.

To see the list of available modules from nf-core, use the following command:

```
nf-core modules \
  list \
  remote
```

To see the list of available modules from msk, use the following command:

{% code overflow="wrap" %}
```
nf-core modules --git-remote git@github.com:mskcc-omics-workflows/modules.git -b main list remote
```
{% endcode %}

To see the list of available subworkflows, replace `modules` in the above commands with `subworkflows`.

To install the `gbcms` module that is available from msk, use the following command:

{% code overflow="wrap" %}
```
nf-core modules --git-remote git@github.com:mskcc-omics-workflows/modules.git -b main install gbcms
```
{% endcode %}

The folder `modules/msk/gbcms` will appear in your local repository and the file `modules.json` will be modified to reflect the change to your local modules, which can be committed and added to your git development branch. To update the module, use the following command:

{% code overflow="wrap" %}
```
nf-core modules --git-remote git@github.com:mskcc-omics-workflows/modules.git -b main update gbcms
```
{% endcode %}

If a component is not in the nf-core or msk modules repositories, consider one of the following options:

1. Create the module as local component using `nf-core modules create`
2. Contribute the component to mskcc-omics-workflows/modules repository by following the [Contributing](contributing.md) and then installing.
3. Contribute the component to the nf-core/modules repository by following [nf-core's guidelines](https://nf-co.re/docs/usage/getting\_started/introduction) and then installing.&#x20;

> _**For mskcc-omics-workflows users:**_&#x20;
>
> Documentation for each available msk module and subworkflow is contained in the Modules and Subworkflows sections.

#### Configurations

Modules and subworkflows should be configured from the pipeline's main modules configuration file `conf/modules.config`

> _**For mskcc-omics-workflows users:**_
>
> Subworkflows may contain a custom configuration file, which will appear under `subworkflows/msk/<example_subworkflow>/nextflow.config`. This file has configurations that are specific to the subworkflow and should be loaded during initialization. Add the line `includeConfig '../subworkflows/msk/<example_subworkflow>/nextflow.config` to the `conf/modules.config` file to apply the configurations to your pipeline. If your pipeline requires configurations different than those in the included file, we recommend that you change them directly in the `modules.config` file.
