# Dockerfile to create container with pre_bcl2fastq
# Push to mpathdms/pre_bcl2fastq:<VER>

FROM python:3.8-slim-buster
LABEL authors="Yu Hu <huy1@mskcc.org>" \
    description="Docker image containing pre-bcl2fastq2.20"

# ADD requirements.txt /
# RUN pip install -r requirements.txt

# 'ps' command is needed by some nextflow executions to collect system stats
# Install procps and clean apt cache
RUN apt-get update \
    && apt-get install -y \
    procps \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# add python scripts
ADD bin/samplesheet.py /
ADD bin/exceptions.py /
ADD bin/create_meta.py /

