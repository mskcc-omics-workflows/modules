---
description: >-
  github:
  https://github.com/mskcc-omics-workflows/tools/tree/feature/nfcore-integration
---

# How to start a new module via nf-core commands

This version uses nf-core commands to manage modules: [https://nf-co.re/developers/modules](https://nf-co.re/developers/modules)

#### Steps:

1. brew install poetry (or using pip)
2. git clone -b feature/nfcore-integration [https://github.com/mskcc-omics-workflows/tools.git](https://github.com/mskcc-omics-workflows/tools.git)
3. cd tools
4. git checkout -b feature/\<your-module-name>
5. poetry install
6. poetry run nf-core modules create fastqc --author @joebloggs --label process\_low --meta
7. you will be able to find your module in `modules` directory, and tests in `tests/modules/<your_module_name>`
8. To run test: poetry run nf-core modules test \<your\_module\_name>
9. To check if the format is matching with nf-core: poetry run nf-core modules lint \<your\_module\_name> --dir .

#### Pros:

1. Directly using nf-core commands, easier for developing new modules and running unit tests

#### Cons:

1. nf-core package has dozens of dependencies that need to install (but it will be just one-time thing)
2. Dockerfile and README.md will need to create manually for each module
3. Since we are using a separate github repo other than nf-core/modules, ALL nf-core commands that need connection to nf-core/modules will not be available
