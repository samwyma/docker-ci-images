FROM docker:stable

RUN apk add --no-cache \
    ca-certificates \
    curl \
    git \
    jq \
    make \
    openssh-client \
    python3 \
    tar \
    wget \
    && pip3 install --upgrade awscli awsebcli pip pipenv