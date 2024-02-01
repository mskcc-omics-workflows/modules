# Image Management

## Docker container registry via JFrog

### JFrog UI: [https://mskcc.jfrog.io/ui/login/](https://mskcc.jfrog.io/ui/login/)

### Description

We can use JFrog platform to store docker container registries used in common shared modules/subworkflows. Pulling from the Artifactory is open access (no authorization needed), but pushing needs access.

### Upload your images/packages

All customized images and packages will be stored in the "docker-local" repository.&#x20;

Step 1. Docker login, when asked for a password, enter the **ci service account** identity token

```
docker login -u<ci_service_account_username> <jfrog_url>
```

For example (contact the team for service account information),

```
docker login -u<ci_service_account_username> https://mskcc.jfrog.io/
```



Step 2. Tag the image

```
docker tag example:0.1.0 <jfrog_url>/<DOCKER_IMAGE>:<DOCKER_TAG>
OR
docker tag <DOCKER_IMAGE_ID> <jfrog_url>/<DOCKER_IMAGE>:<DOCKER_TAG>
```

For example,

```
docker tag example:0.1.0 mskcc.jfrog.io/omicswf-docker-test-local/mskcc-omics-workflows/example:0.1.0cv2/example:0.1.0
OR
docker tag <DOCKER_IMAGE_ID> <jfrog_url>/omicswf-docker-test-local/mskcc-omics-workflows/example:0.1.0
```

NOTE: we have several local folders to store images:

* omicswf-docker-dev-local -- for develop purposes
* omicswf-docker-test-local -- for testing purposes, docker images (if needed to store in JFrog) should be uploaded to this repository along with pull request from feature branch to develop branch in the common library github
* omicswf-docker-prod-local -- for production purposes, docker images should be uploaded along with the official release (from develop branch to main branch). We can just make copies from `omicswf-docker-test-local` to `omicswf-docker-prod-local`on JFrog platform directly



Step 3. Push the image

```
docker push <jfrog_url>/<DOCKER_IMAGE>:<DOCKER_TAG>
```

For example,

```
docker push mskcc.jfrog.io/omicswf-docker-test-local/mskcc-omics-workflows/example:0.1.0
```



### Download images/packages

#### Docker:

Docker login, when asked for a password, enter **cd service account** identity token

```
docker login -u<cd_service_account_username> <jfrog_url>
```

For example (contact the team for service account information),

```
docker login -u<cd_service_account_username> https://mskcc.jfrog.io
```

Pull images

```
docker pull <jfrog_url>/<DOCKER_IMAGE>:<DOCKER_TAG>
```

```
docker pull mskcc.jfrog.io/omicswf-docker-dev-local/mskcc-omics-workflows/example:0.1.0
```

#### Singularity:

Set up singularity authentication before running the test. This is for bypassing the auth from Jfrog:

```
export SINGULARITY_DOCKER_USERNAME=<cd_server_account_username>
export SINGULARITY_DOCKER_PASSWORD=<access_token>
```

```
singularity pull docker://<jfrog_url>/<DOCKER_IMAGE>:<DOCKER_TAG>
```

For example,

```
singularity pull docker://mskcc.jfrog.io/omicswf-docker-dev-local/mskcc-omics-workflows/example:0.1.0
```

### List of available images

[https://mskcc.jfrog.io/ui/native/omicswf-docker-dev-virtual/mskcc-omics-workflows/](https://mskcc.jfrog.io/ui/native/omicswf-docker-dev-virtual/mskcc-omics-workflows/)
