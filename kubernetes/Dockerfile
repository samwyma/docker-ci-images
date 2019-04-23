FROM alpine:latest as kube
ENV VERSION="v1.11.3"
RUN apk add wget \
    && wget -q https://storage.googleapis.com/kubernetes-release/release/${VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

FROM alpine:latest as helm
ENV VERSION="v2.13.1"
RUN apk add wget \
    && wget -q https://storage.googleapis.com/kubernetes-helm/helm-${VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm

FROM alpine:latest as authenticator
ENV VERSION="1.11.5"
RUN apk add wget \
    && wget -q https://amazon-eks.s3-us-west-2.amazonaws.com/${VERSION}/2018-12-06/bin/linux/amd64/aws-iam-authenticator -O /usr/local/bin/aws-iam-authenticator \
    && chmod +x /usr/local/bin/aws-iam-authenticator

FROM landtech/ci-node:latest
COPY --from=kube /usr/local/bin/kubectl /usr/local/bin
COPY --from=helm /usr/local/bin/helm /usr/local/bin
COPY --from=authenticator /usr/local/bin/aws-iam-authenticator /usr/local/bin
COPY install_kube_iam_user.sh /usr/bin/install_kube_iam_user.sh

ENV AWS_DEFAULT_REGION=eu-west-1

RUN apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    git \
    openssh \
    libressl-dev \
    # credstash
    && apk --no-cache --virtual credstash-dependencies add \
    libc-dev \
    libffi-dev \
    gcc \
    make \
    python3-dev \
    && pip install credstash \
    && apk del credstash-dependencies \
    # yq
    && pip install yq
