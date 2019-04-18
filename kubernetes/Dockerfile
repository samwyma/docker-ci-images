FROM landtech/ci-node:latest

# Note: Latest version of kubectl may be found at:
# https://aur.archlinux.org/packages/kubectl-bin/
ENV KUBE_VERSION="v$(curl 'https://aur.archlinux.org/rpc?v=5&type=info&arg=kubectl-bin' | jq -r '.results[].Version' | cut -d '-' -f 1)"
# Note: Latest version of helm may be found at:
# https://github.com/kubernetes/helm/releases
ENV HELM_VERSION="$(curl --silent -L 'https://api.github.com/repos/kubernetes/helm/releases/latest' | jq -r .tag_name)"

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
    && wget -q https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator -O /usr/local/bin/aws-iam-authenticator \
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