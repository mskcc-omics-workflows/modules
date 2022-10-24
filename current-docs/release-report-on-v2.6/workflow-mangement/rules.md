# Rules

#### Workflows require stronger coding than modules. It does not only involve writing workflows, but also nextflow channel, asynchronous processes, groovy functions and methods. My recommendation is to read the documents from nextflow and examples from nf-core, as well as any training materials in this gitbook and online. It requires some learning time.

#### Demultiplexing workflow should be working. Please feel free to use it as an example/template. Also, in the `output/pipeline_info` folder of this repo, you will be able to find nextflow features to track processes and some very nice figures/htmls.&#x20;

#### Modules in workflow

1. Modules downloaded/installed from _mskcc-omics-workflows/tools_ or _nf-core/modules_ should not be changed. If there is a need to change the modules,
   * If modules are from _msk-tools_:  Change them in tools.git and update in workflow
   * If modules are from _nf-core/modules_ OR if modules are only limited to the current workflow: Make the change first and do `nf-core modules patch <Module_Name>`. That way, there will be a `<Module_Name>.diff` file generated in the module folder. It will be applied even when you update the modules. For more reference, [https://nf-co.re/tools/#create-a-patch-file-for-a-module](https://nf-co.re/tools/#create-a-patch-file-for-a-module)

#### Subworkflows

1. To test subworkflow, please DO NOT use dummy parameters or inputs. All inputs should come in nextflow.config file. No hard-coded lines.&#x20;
2. Subworkflows are used to combine multiple modules together. No supportive scripts should be used in subworkflows.

#### Workflows

1. Workflows are combinations of subworkflows, supportive scripts, and input validation&#x20;
2. Additional nextflow features are added to nextflow.config of workflows
3. The inputs of workflow should be as simple as possible, for example, a folder. All the intermediate inputs for subworkflows/modules need to be processed in workflow/supportive scripts.

#### Supportive scripts and input validation

1. In `lib` and `bin` folders, preferring to groovy scripts



