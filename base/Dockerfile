FROM docker:stable

RUN apk add --no-cache \
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
  && pip3 install --upgrade awscli awsebcli pip pipenv \
  # credstash
  && apk --no-cache --virtual credstash-dependencies add \
  libffi-dev \
  && pip install credstash \
  && apk del credstash-dependencies \
  && pip3 install PyYaml==3.10 \
  # bats
  && git clone https://github.com/sstephenson/bats.git \
  && cd bats \
  && ./install.sh /usr/local \
  && cd ../ \
  && rm -rf bats
