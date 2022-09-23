# Rules

#### How to install a module?

1. If we need to download nf-core modules directly, run `nf-core modules --git-remote git@github.com:nf-core/modules.git install fastqc` . And this module will be installed in `modules/nf-core/modules` in the workflow codebase
2. If we need to download modules from our own tools repo, just do `nf-core modules install <module_name>` . And this module will be installed in `modules/mskcc-omics-workflows/tools/` in the workflow codebase

#### Modules in workflow

1. Modules downloaded/installed from _mskcc-omics-workflows/tools_ or _nf-core/modules_ should not be changed. If there is a need to change the modules,
   * If modules are from _mskcc-omics-workflows/tools_:  Change them in tools.git and update in workflow
   * If modules are from nf-core/modules OR if modules are only limited to the current workflow: Make the change first and do `nf-core modules patch <Module_Name>`. That way, there will be a `<Module_Name>.diff` file generated in the module folder. It will be applied even when you update the modules. For more reference, [https://nf-co.re/tools/#create-a-patch-file-for-a-module](https://nf-co.re/tools/#create-a-patch-file-for-a-module)

