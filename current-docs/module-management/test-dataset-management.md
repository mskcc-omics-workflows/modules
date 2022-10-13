# Test dataset management

### For small test datasets (less than 100 MB)

* We use [https://github.mskcc.org/MSKCC-Omics-Workflows/tools-test-dataset](https://github.mskcc.org/MSKCC-Omics-Workflows/tools-test-dataset)
* Create a feature branch in this repo, and add your test data to <mark style="color:blue;">\<your\_module\_name>/</mark> in root directory
* This repo is a submodule of our tools repo, where you can follow instructions in other pages to access the test datasets

### For large test datasets (more than 100 MB)

* We are now using docker images to store LARGE data files
*   Dockerfile example: [https://github.mskcc.org/MSKCC-Omics-Workflows/tools-test-dataset/blob/master/merge\_gzip/Dockerfile](https://github.mskcc.org/MSKCC-Omics-Workflows/tools-test-dataset/blob/master/merge\_gzip/Dockerfile) (NOTES: <mark style="color:red;">VOLUME</mark> is used here to connect container and host directory). Please use the following name for any of your module test datasets:

    ```textile
    VOLUME /test-datasets
    ```
* Save the Dockerfile in [https://github.mskcc.org/MSKCC-Omics-Workflows/tools-test-dataset](https://github.mskcc.org/MSKCC-Omics-Workflows/tools-test-dataset)
  * Create a feature branch in this repo, and add your Dockerfile to <mark style="color:blue;">\<your\_module\_name>/</mark> in root directory
* Build the image with the name with <mark style="color:red;">"testdata-\<your\_module\_name>"</mark>, for example, "testdata-merge\_gzip"
* Upload the docker image to [https://github.com/orgs/mskcc-omics-workflows/packages](https://github.com/orgs/mskcc-omics-workflows/packages) (See instructions in Module Management about publishing github package)
*   Steps to pull test datasets from a docker image:

    1. {% code overflow="wrap" %}
       ```
       docker run --name <your_container_name> ghcr.io/mskcc-omics-workflows/testdata-<your_module_name>:0.1.0
       ```
       {% endcode %}
    2. ```textile
       docker cp <your_container_name>:/test-datasets <your_target_location>
       ```
    3. Edit your test.yml file to include your target locations where the test data is located and run the test.


* <mark style="color:orange;">**`TODO:`**</mark>
  * Right now, this is for individual modules. We can create a general docker image or a command to pull multiple test datasets at the same time.
