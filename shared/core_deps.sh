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
curl -s -o /root/.aws/cli/alias https://raw.githubusercontent.com/landtechnologies/reformation/master/assets/aws-alias

pip3 install awsebcli==3.14.7

# pip
pip3 install --upgrade \
  pip \
  pipenv \
  docker-compose \ # This must be installed after awsebcli==3.14.7 as awsebcli v3.14.7 has requirements for docker-compose >=1.21.2,<1.22.0
  credstash

# bats
git clone https://github.com/sstephenson/bats.git
cd bats
./install.sh /usr/local
cd ../
rm -Rf bats
