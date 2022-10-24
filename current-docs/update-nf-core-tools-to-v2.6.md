# Release report on v2.6

{% embed url="https://github.com/nf-core/tools/releases/tag/2.6" %}

### Changes from MSK

#### Module side

* Default github repo is pointing to [https://github.com/mskcc-omics-workflows/tools.git](https://github.com/mskcc-omics-workflows/tools.git)
* Enable HPC testing for module unit testings
* Add testing processes with tags `hpc_<your_module_name>` in linting for module
* Subfolders in `modules` and `tests/modules` are renamed from `nf-core` to `msk-tools`

#### Workflow side

* `nf_core/modules/modules_repo.py` updated remote url from NF\_CORE\_MODULES\_REMOTE to NF\_CORE\_MODULES\_NAME

#### Tutorial on how to update your feature branch to the new version:

1. Pull all the latest changes from develop or master branch
2. In `modules` folder, move your working module to `msk-toos` folder
3. In `tests/modules` folder, move your working module to `msk-tools` folder
   1. In main.nf script, update the relative path to locate the main script from `modules` folder&#x20;
   2. In test.yml, update from `tests/modules/<module-name>` to `tests/modules/msk-tools/<module-name>`, and from `modules/<module-name>` to `modules/msk-tools/<module-name>`
4. `In tests/config/pytest_modules.yml`, update the paths of your modules  to include `msk-tools`
5. Make sure all testings pass for the module &#x20;
