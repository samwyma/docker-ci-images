FROM docker:stable

RUN apk add --no-cache \
    bash \
    ca-certificates \
    coreutils \
    curl \
    git \
    jq \
    make \
    openssh-client \
    python3 \
    tar \
    wget \
    zip \
    && pip3 install --upgrade awscli awsebcli pip pipenv