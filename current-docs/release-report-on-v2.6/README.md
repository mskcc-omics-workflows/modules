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
