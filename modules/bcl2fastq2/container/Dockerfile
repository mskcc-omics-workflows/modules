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
RUN mkdir -p /usr/local/share/xsl/demux
RUN mkdir -p /usr/local/share/xsl/common
COPY xsl/demux/* /usr/local/share/xsl/demux/
COPY xsl/common/* /usr/local/share/xsl/common/
RUN chmod +x -R /usr/local/share/xsl
RUN mkdir -p /usr/local/share/css
COPY css/* /usr/local/share/css/
RUN chmod +x -R /usr/local/share/css
