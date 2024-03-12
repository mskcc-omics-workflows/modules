FROM ubuntu:18.04

LABEL maintainer="John Orgera <orgeraj@mskcc.org>" \
    version.image="0.3.2-hotfix" \
    version.neoantigen-dev="0.3.2-hotfix" \
    version.netMHC="4.0a" \
    version.netMHCpan="4.1" \
    version.python="2.7.15rc1"

ENV TMPDIR="/tmp"
ENV NEOANTIGEN_VERSION 0.3.2-hotfix

RUN apt-get update && apt-get install -y \
    tcsh \
    libnss-sss \
    git \
    python-pip \
    build-essential \
    wget \
    gawk \
    vim \
    &&  apt-get clean && apt-get purge \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# For copying netMHC and netMHCpan gz files for installation. This Dockerfile expects them to be in the same directory
# NOTE: You will have to acquire them through their website, as they are not readily available for download from:
#https://services.healthtech.dtu.dk/software.php
COPY netMHC*.gz /tmp/netMHC/


# Install netMHCpan, which requires modifying entries within the script; also make sure the permissions for the stuff inside the tar.gz is at least drwxr-xr-x
RUN tar -xvf /tmp/netMHC/netMHCpan-4.1b.Linux.tar.gz -C /usr/local/bin \
    && sed -i 's|'/net/sund-nas.win.dtu.dk/storage/services/www/packages/netMHCpan/4.1/netMHCpan-4.1'|'/usr/local/bin/netMHCpan-4.1'|' /usr/local/bin/netMHCpan-4.1/netMHCpan \
    && sed -i '32c\setenv NETMHCpan /usr/local/bin/netMHCpan-4.1/Linux_x86_64' /usr/local/bin/netMHCpan-4.1/netMHCpan \ 
    && chmod -R 777 /usr/local/bin/netMHCpan-4.1

# Install netMHCpan data; directory needed permission changes, drwxr-xr-x
RUN cd /usr/local/bin/netMHCpan-4.1/ \
    && wget https://services.healthtech.dtu.dk/services/NetMHCpan-4.1/data.tar.gz \
    && tar -zxvf data.tar.gz \
    && chmod -R o+rx data/ \
    && rm -rf data.tar.gz

COPY generateMutFasta.py /usr/local/bin/
COPY Homo_sapiens.GRCh37.75.cdna.all.fa.gz /usr/local/bin/
COPY Homo_sapiens.GRCh37.75.cds.all.fa.gz /usr/local/bin/



RUN set -xe \
    && apt-get update -y \
    && apt-get install -y python3.8 \
    && apt-get install -y python3-pip
    

RUN python3 -m pip install --upgrade pip && \
    pip3 install numpy==1.15.4 && \
    pip3 install pandas==0.23.4 && \
    pip3 install python-dateutil && \
    pip3 install psutil



# Add neoantigen-dev
RUN cd /tmp \
    && wget https://github.com/taylor-lab/neoantigen-dev/archive/${NEOANTIGEN_VERSION}.tar.gz -O neoantigen-dev-${NEOANTIGEN_VERSION}.tar.gz

RUN tar -xvf /tmp/neoantigen-dev-${NEOANTIGEN_VERSION}.tar.gz -C /usr/local/bin \
    && mv /usr/local/bin/neoantigen-dev-${NEOANTIGEN_VERSION}/ /usr/local/bin/neoantigen/ \
    && cd /usr/local/bin/neoantigen/ \
    && pip install -r requirements.txt
