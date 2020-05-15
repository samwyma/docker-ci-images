#!/usr/bin/env sh

set -e

# build dependencies
apk add --no-cache --virtual=dependencies \
  libressl-dev \
  libc-dev \
  libffi-dev \
  gcc \
  python3-dev

# packages
apk add --no-cache \
  bash \
  ca-certificates \
  coreutils \
  curl \
  git \
  grep \
  jq \
  libressl \
  lsof \
  make \
  netcat-openbsd \
  ncurses \
  openssh-client \
  python3 \
  rsync \
  tar \
  wget \
  zip \
  util-linux

# aws cli
pip3 install --upgrade --no-cache-dir \
  awscli
mkdir -p /root/.aws/cli
curl --fail -s -o /root/.aws/cli/alias https://raw.githubusercontent.com/landtechnologies/reformation/master/assets/aws-alias

# pip
pip3 install --upgrade --no-cache-dir \
  pip \
  pipenv \
  credstash \
  docker-compose \
  yq

# bats-core
git clone https://github.com/bats-core/bats-core.git
cd bats-core
./install.sh /usr/local
cd ../
rm -Rf bats-core

# clean up
apk del --purge dependencies
rm -rf /tmp/* /var/cache/apk/*
