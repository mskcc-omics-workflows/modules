FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y libncurses5-dev \
    libbz2-dev \
    liblzma-dev \
    libcurl4-gnutls-dev \
    zlib1g-dev \
    libssl-dev \
    gcc \
    wget \
    make \
    perl \
    bzip2 \
    pkg-config \
    libpng-dev \
    libjpeg8-dev \
    libfreetype6-dev \
    unzip \
    g++

RUN apt-get install -y git



RUN set -xe \
    && apt-get update -y \
    && apt-get install -y python3.8 \
    && apt-get install -y python3-pip


RUN git clone https://github.com/Sentieon/vcflib.git /usr/bin/vcflib/


RUN python3 -m pip install --upgrade pip && \
    pip3 install numpy && \
    pip3 install pandas


COPY eval_phyloWGS.py /usr/bin
RUN chmod +rx /usr/bin/eval_phyloWGS.py
