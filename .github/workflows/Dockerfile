FROM debian:stable-slim

ARG TASK_VERSION=v3.29.1
# For task_linux_amd64.deb
ARG TASK_CHECKSUM=e411770abf73d5e094100ab7a1c8278f35b591ecadbfd778200b6b2ad1ee340b

RUN apt-get update && \
    apt-get -y install parallel jq curl && \
    curl -L -o /tmp/task_linux_amd64.deb https://github.com/go-task/task/releases/download/$TASK_VERSION/task_linux_amd64.deb && \
    sha256sum /tmp/task_linux_amd64.deb | grep -q $TASK_CHECKSUM && \
    dpkg -i /tmp/task_linux_amd64.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
