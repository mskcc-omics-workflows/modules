# Rules

#### Version control

* Version control of the bioinformatics tools will be tracked via containers. In the nextflow.config file, we can specify the containers that we need to run tools, regardless of the containers written inside of the modules. That way we can run the same modules with different versions of containers.
* Reference: [https://www.nextflow.io/docs/latest/container.html](https://www.nextflow.io/docs/latest/container.html)

#### If a module is already in nf-core/modules, there is no need to create our own. But we need a container for the module

* Need unit testing with our own customized config???
* `nf-core modules --git-remote git@github.com:nf-core/modules.git add cutadapt?`
* To be discussed...

#### Need to download a module for nf-core/modules as a template for our own customized usage?&#x20;

* &#x20;Well, we will need to copy and paste from nf-core/modules.



#### Module testing on HPC

* To be developed...
