# Rules

#### Modules in workflow

1. Modules downloaded/installed from _mskcc-omics-workflows/tools_ or _nf-core/modules_ should not be changed. If there is a need to change the modules,
   * If modules are from _mskcc-omics-workflows/tools_:  Change them in tools.git and update in workflow
   * If modules are from nf-core/modules OR if modules are only limited to the current workflow: Make the change first and do `nf-core modules patch <Module_Name>`. That way, there will be a `<Module_Name>.diff` file generated in the module folder. It will be applied even when you update the modules. For more reference, [https://nf-co.re/tools/#create-a-patch-file-for-a-module](https://nf-co.re/tools/#create-a-patch-file-for-a-module)

