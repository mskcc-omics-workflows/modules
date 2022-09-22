
FROM ubuntu:18.04
LABEL authors="Yu Hu" \
    description="Docker image containing merge tool to merge raw fastq files"

# 'ps' command is needed by some nextflow executions to collect system stats
# Install procps and clean apt cache
RUN apt-get update \
    && apt-get install -y \
    procps \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Zcat and gzip cmds
RUN apt-get install gzip
RUN which zcat
RUN which gzip