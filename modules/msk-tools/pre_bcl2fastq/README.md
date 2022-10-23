## PRE_BCL2FASTQ

#### Description:

This is the module to prepare metadata for bcl2fastq

#### Usage:

Inputs:

- RunInfo.xml
- RunParameters.xml

Outputs:

- meta.csv with relevant metadata of the sequencing runs

Testing/Example:

```
nextflow run tests/main.nf -profile docker
```

#### Note:

This module is running a python script which is pushed to the docker images. To edit the python scripts in bin repo, the docker image has to be renewed also.

```
cd <path>/pre_bcl2fastq
docker build -t mpathdms/pre-bcl2fastq:<version> .
docker push mpathdms/pre-bcl2fastq:<version>
```
