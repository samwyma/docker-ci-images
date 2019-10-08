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

# aws cli
pip3 install --upgrade awscli
mkdir -p /root/.aws/cli
curl -s -o /root/.aws/cli/alias https://raw.githubusercontent.com/landtechnologies/reformation/master/assets/aws-alias

pip3 install awsebcli==3.14.7

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

# bats
git clone https://github.com/sstephenson/bats.git
cd bats
./install.sh /usr/local
cd ../
rm -Rf bats
