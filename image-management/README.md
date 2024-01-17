# Image Management

## Docker container registry via JFrog

### JFrog UI: [https://mskcc.jfrog.io/ui/login/](https://mskcc.jfrog.io/ui/login/)

### Description

We can use JFrog platform to store docker container registries used in common shared modules/subworkflows. Pulling from the Artifactory is open access (no authorization needed), but pushing needs access.

### Upload your images/packages

All customized images and packages will be stored in the "docker-local" repository.&#x20;

Step 1. Docker login, when asked for a password, enter the **ci service account** identity token

```
docker login -u<username> <jfrog_url>
```

Step 2. Tag the image

```
docker tag example:0.1.0 <jfrog_url>/omicswf-docker-dev-local/mskcc-omics-workflows/example:0.1.0
```

Step 3. Push the image

```
docker push <jfrog_url>/omicswf-docker-dev-local/mskcc-omics-workflows/example:0.1.0
```

### Download images/packages

#### Docker:

Docker login, when asked for a password, enter **cd service account** identity token

```
docker login -u<username> <jfrog_url>
```

```
docker pull <jfrog_url>/omicswf-docker-dev-local/mskcc-omics-workflows/<DOCKER_IMAGE>:<DOCKER_TAG>
```

#### Singularity:

Set up singularity authentication before running the test. This is for bypassing the auth from Jfrog:

```
export SINGULARITY_DOCKER_USERNAME=<cd_server_account>
export SINGULARITY_DOCKER_PASSWORD=<access_token>
```

```
singularity pull docker://<jfrog_url>/omicswf-docker-dev-local/mskcc-omics-workflows/example:0.1.0
```

