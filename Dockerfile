# syntax=docker/dockerfile:1
FROM ubuntu:22.04
LABEL org.opencontainers.image.authors="Graham Cropley <graham.cropley@gmail.com>"

RUN apt-get update
RUN apt-get install -y curl bash python3 python3-pip wget libssl-dev libffi-dev build-essential jq

RUN mkdir /app
WORKDIR /app

RUN wget https://github.com/nginx-proxy/docker-gen/releases/download/0.14.5/docker-gen-linux-amd64-0.14.5.tar.gz
RUN tar xvzf docker-gen-linux-amd64-0.14.5.tar.gz -C /usr/local/bin

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

ADD https://raw.githubusercontent.com/grahamcropley/AzureDnsAutoUpdater/refs/heads/main/app/azuredns.tmpl /app/
ADD https://raw.githubusercontent.com/grahamcropley/AzureDnsAutoUpdater/refs/heads/main/app/update-azuredns.sh /app/
RUN chmod a+rx /app/update-azuredns.sh

ENV DOCKER_HOST=unix:///var/run/docker.sock

ENTRYPOINT [ \
  "docker-gen", \
  "-only-published", \
  "-watch", \
  "-notify", "/bin/bash /app/update-azuredns.sh", \
  "-notify-output", \
  "/app/azuredns.tmpl", \
  "/app/azuredns.zone" \
]
