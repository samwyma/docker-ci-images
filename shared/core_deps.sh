#!/usr/bin/env sh

set -e

# Core deps
apk add --no-cache \
  bash \
  ca-certificates \
  coreutils \
  curl \
  git \
  grep \
  jq \
  make \
  openssh-client \
  gcc \
  python3-dev \
  libc-dev \
  make \
  python3 \
  tar \
  wget \
  zip \
  util-linux \
  libressl-dev \
  libffi-dev

# Pip deps
pip3 install --upgrade awscli awsebcli pip pipenv credstash

pip3 install PyYaml==3.10

# bats
git clone https://github.com/sstephenson/bats.git \
  && cd bats \
  && ./install.sh /usr/local \
  && cd ../ \
  && rm -rf bats
