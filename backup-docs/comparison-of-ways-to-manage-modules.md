# Comparison of ways to manage modules

|                      Points                      |                                                   On our own                                                  |                                                                          Via nfcore cmds                                                                          |
| :----------------------------------------------: | :-----------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------: |
|         Write a new module with templates        |                                Using our own templates downloaded from nf-core                                |                                                          Using up-to-date templates from nf-core directly                                                         |
|            Write unit tests for module           |                                           Included in the templates                                           |                                                                     Included in the templates                                                                     |
|                  Run a unit test                 |                            Need provide full command: nextflow run tests/main.nf...                           |                                                                           nfcore command                                                                          |
|                 Testing strategy                 |                                   No other framework, just nextflow command                                   |                                                                          pytest-workflow                                                                          |
|       Check the format of a finished module      |                                                  Unavailable                                                  |                                                                           nfcore command                                                                          |
|             Dockerfile and README.md             |                                                   Available                                                   |                                                                      Need to create manually                                                                      |
|            Packages needed to install            |                                                   Very light                                                  |                                                    Need to install nf-core package with dozens of dependencies                                                    |
| Download an existing module from nf-core/modules |                                                     Manual                                                    |                                                      Manual on module level; nfcore command on pipeline level                                                     |
|          Datasets used for unit testings         |                                              Will be a submodule                                              |                                                                        Will be a submodule                                                                        |
|                Potential confusion               |                                                      None                                                     | ALL nf-core commands that need connection to nf-core/modules will not be available. This includes cmds for downloading our own modules to workflow/pipeline repos |
|                Potential solution                | **Development to mimic nf-core commands to fit our needs. We can update once nf-core releases a new version** |                                                                                None                                                                               |

#### For the last point:

{% embed url="https://github.com/mskcc-omics-workflows/nfcore-cmd" %}

The third way: Using the same nf-core commands to create/modify a module, and same nf-core commands to install/remove a module at pipeline/workflow level

Need to download a module for nf-core/modules? Well....that's to be discussed...

