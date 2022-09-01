# Dockerfile to create container with bcl2fastq
# Push to nfcore/bcl2fastq:<VER>

FROM debian:bullseye-slim
LABEL authors="Yu Hu <huy1@mskcc.org>" \
    description="Docker image containing bcl2fastq2.20"
# Disclaimer: this container is not provided nor supported by Illumina
# 'ps' command is needed by some nextflow executions to collect system stats
# Install procps and clean apt cache
RUN apt-get update \
    && apt-get install -y \
    procps \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Link hostname cmd to fix hardcoded path
RUN ln -s /bin/hostname /usr/bin/hostname
COPY usr/local/bin/bcl2fastq /usr/local/bin/bcl2fastq
RUN chmod +x /usr/local/bin/bcl2fastq

# xsl files for generating the reports
RUN mkdir -p /user/local/share/xsl/demux
COPY demux/* /user/local/share/xsl/demux/
RUN chmod +x /user/local/share/xsl/demux