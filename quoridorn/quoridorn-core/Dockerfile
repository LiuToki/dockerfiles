FROM ubuntu:20.10

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y wget git apt-utils

# for quoridorn-server
RUN apt-get install -y nodejs npm

WORKDIR /data
RUN git clone https://github.com/HillTopTRPG/quoridorn-server.git && \
    cd quoridorn-server && \
    npm install && \
    npm run build && \
    npm run node-server