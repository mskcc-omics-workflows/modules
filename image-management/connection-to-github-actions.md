# Connection to GitHub Actions

## Description

Create an image everytime there is a change in main branch (or other branch) and upload it to JFrog as Builds.

### Step 1. Create GitHub Secrets

* In your GitHub repository go to: Settings > Secrets & Variables > Actions
* Click New repository secret
* In the Name field, enter **JF\_URL**
* In the Secret field, enter **\<JFrog\_URL>**
* Click on the Add secret button
* Click New repository secret
* In the Name field, enter **JF\_ACCESS\_TOKEN**
* In the Secret field, enter the Access Token
* Click on the Add secret button

### Step 2. Create Workflow File

* Create or update your .github/workflows/build-publish.yml YAML file with the following content
* Example Script:

```
name: Build and Tag Docker Image

on:
  push:
    branches:
      - main
      
jobs:
  build-and-tag:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Setup JFrog CLI
        uses: jfrog/setup-jfrog-cli@v3
        env:
          JF_URL: ${{ secrets.JF_URL }}
          JF_ACCESS_TOKEN: ${{ secrets.JF_ACCESS_TOKEN }}

      - name: Build Tag and push Docker Image
        env:
          IMAGE_NAME:  ${{ secrets.JF_URL }}/<project>-docker/jfrog-docker-build-example:${{ github.run_number }}
        run: |
          jf docker build -t $IMAGE_NAME .
          jf docker push $IMAGE_NAME
          
      - name: Publish Build info With JFrog CLI
        env:
          # Generated and maintained by GitHub
          JFROG_CLI_BUILD_NAME: jfrog-docker-build-example
          # JFrog organization secret
          JFROG_CLI_BUILD_NUMBER : ${{ github.run_number }}
        run: |
          # Export the build name and build nuber
          # Collect environment variables for the build
          jf rt build-collect-env
          # Collect VCS details from git and add them to the build
          jf rt build-add-git
          # Publish build info
          jf rt build-publish
```

* In your Github repository, under the Actions tab you should see a workflow run\




