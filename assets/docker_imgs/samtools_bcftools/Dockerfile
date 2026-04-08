# base image
FROM quay.io/bedrock/ubuntu:jammy-20240808

RUN apt-get update
RUN apt-get install -y gcc
RUN apt-get install -y make
RUN apt-get install -y libbz2-dev
RUN apt-get install -y zlib1g-dev
RUN apt-get install -y libncurses5-dev 
RUN apt-get install -y libncursesw5-dev
RUN apt-get install -y liblzma-dev
RUN apt-get install -y wget tar lbzip2:

WORKDIR /usr/bin
RUN wget https://github.com/samtools/htslib/releases/download/1.20/htslib-1.20.tar.bz2
RUN tar -xf htslib-1.20.tar.bz2
WORKDIR htslib-1.20
RUN ./configure
RUN make
RUN make install

WORKDIR /usr/bin
RUN wget https://github.com/samtools/samtools/releases/download/1.20/samtools-1.20.tar.bz2
RUN tar -xf samtools-1.20.tar.bz2
WORKDIR samtools-1.20
RUN ./configure
RUN make
RUN make install

WORKDIR /usr/bin
RUN wget https://github.com/samtools/bcftools/releases/download/1.20/bcftools-1.20.tar.bz2
RUN tar -xf bcftools-1.20.tar.bz2
WORKDIR bcftools-1.20
RUN ./configure
RUN make
RUN make install

ENV PATH="$PATH:/usr/bin/bcftools-1.20:/usr/bin/samtools-1.20:/usr/bin/htslib-1.20"

WORKDIR /
