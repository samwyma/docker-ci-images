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

FROM alpine:latest as argo
ENV VERSION="v2.3.0"
RUN apk add wget \
  && wget -q https://github.com/argoproj/argo/releases/download/${VERSION}/argo-linux-amd64 -O /usr/local/bin/argo \
  && chmod +x /usr/local/bin/argo

FROM alpine:latest as render
ENV RENDER_VERSION=v0.1.3
RUN apk add curl \
  && curl -L -s https://github.com/VirtusLab/render/releases/download/${RENDER_VERSION}/render-linux-amd64 -o /usr/local/bin/render \
  && chmod +x /usr/local/bin/render

FROM landtech/ci-node:latest
COPY --from=kube /usr/local/bin/kubectl /usr/local/bin
COPY --from=helm /usr/local/bin/helm /usr/local/bin
COPY --from=authenticator /usr/local/bin/aws-iam-authenticator /usr/local/bin
COPY --from=argo /usr/local/bin/argo /usr/local/bin
COPY --from=render /usr/local/bin/render /usr/local/bin
COPY kubernetes/install_kube_iam_user.sh /usr/bin/install_kube_iam_user.sh

ENV AWS_DEFAULT_REGION=eu-west-1

RUN apk add --no-cache \
  openssh \
  # yq
  && pip install yq \
  # Init helm client
  && helm init --client-only
