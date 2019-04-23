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
    util-linux \
    libressl-dev \
    && pip3 install --upgrade awscli awsebcli pip pipenv \
    # credstash
    && apk --no-cache --virtual credstash-dependencies add \
    libc-dev \
    libffi-dev \
    gcc \
    make \
    python3-dev \
    && pip install credstash \
    && apk del credstash-dependencies