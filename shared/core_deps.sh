#!/usr/bin/env sh

set -e

# core
apk add --no-cache \
  ca-certificates \
  git \
  openssh-client \
  python3

# tools
apk add --no-cache \
  bash \
  coreutils \
  curl \
  grep \
  jq \
  make \
  tar \
  wget \
  zip \
  util-linux

# pip
pip3 install --upgrade pip pipenv
pip3 install --upgrade awscli awsebcli
pip3 install PyYaml==3.10

# credstash
apk add --no-cache \
  libressl-dev
apk add --no-cache --virtual credstash-build-dependencies \
  libc-dev \
  libffi-dev \
  gcc \
  make \
  python3-dev
pip3 install --upgrade credstash
apk del credstash-build-dependencies

# aws extensions
git clone https://github.com/landtechnologies/aws-extensions.git /usr/local/bin

# bats
git clone https://github.com/sstephenson/bats.git
cd bats
./install.sh /usr/local
cd ../
rm -rf bats
