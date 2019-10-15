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

# build
apk add --no-cache \
  libressl-dev \
  libc-dev \
  libffi-dev \
  gcc \
  make \
  python3-dev

# aws cli
pip3 install --upgrade awscli
mkdir -p /root/.aws/cli
curl --fail -s -o /root/.aws/cli/alias https://raw.githubusercontent.com/landtechnologies/reformation/master/assets/aws-alias

# pip
pip3 install --upgrade \
  pip \
  pipenv \
  docker-compose \
  credstash

# assert
curl -o /usr/local/bin/assert.sh https://raw.github.com/lehmannro/assert.sh/v1.1/assert.sh

# bats
git clone https://github.com/sstephenson/bats.git
cd bats
./install.sh /usr/local
cd ../
rm -Rf bats
