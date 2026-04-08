FROM quay.io/nf-core/ubuntu:24.04

WORKDIR /usr/share
RUN apt-get update
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y git python3-pip python3-biopython
RUN git clone https://github.com/jenniferlu717/KrakenTools.git

WORKDIR /home/ubuntu
