FROM landtech/ci-node:latest

# https://aur.archlinux.org/packages/kubectl-bin/
ENV KUBE_VERSION="v1.11.3"

# https://github.com/kubernetes/helm/releases
ENV HELM_VERSION="v2.13.1"

# https://github.com/kubernetes/helm/releases
ENV IAM_AUTHENTICATOR_VERSION="1.11.5"

RUN apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    git \
    openssh \
    # kubectl and helm
    && wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && wget -q https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    # aws-iam-authenticator
    && wget -q https://amazon-eks.s3-us-west-2.amazonaws.com/${IAM_AUTHENTICATOR_VERSION}/2018-12-06/bin/linux/amd64/aws-iam-authenticator -O /usr/local/bin/aws-iam-authenticator \
    && chmod +x /usr/local/bin/aws-iam-authenticator \
    # credstash
    && apk --no-cache --virtual credstash-dependencies add \
    libc-dev \
    libffi-dev \
    libressl-dev \
    gcc \
    make \
    python3-dev \
    && pip install credstash \
    && apk del credstash-dependencies \
    # yq
    && pip install yq

COPY install_kube_iam_user.sh /usr/bin/install_kube_iam_user.sh

ENV AWS_DEFAULT_REGION=eu-west-1