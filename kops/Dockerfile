
FROM alpine:latest as kops
ENV KOPS_VERSION=1.11.1
RUN apk add curl \
  && curl -L -s https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-linux-amd64 -o /usr/local/bin/kops \
  && chmod +x /usr/local/bin/kops

FROM golang:alpine as golang
RUN apk add git \
  && go get github.com/google/go-jsonnet/cmd/jsonnet \
  && go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb \
  && go get github.com/brancz/gojsontoyaml

FROM alpine:latest as render
ENV RENDER_VERSION=v0.1.3
RUN apk add curl \
  && curl -L -s https://github.com/VirtusLab/render/releases/download/${RENDER_VERSION}/render-linux-amd64 -o /usr/local/bin/render \
  && chmod +x /usr/local/bin/render

FROM landtech/ci-kubernetes:latest
COPY --from=kops /usr/local/bin/kops /usr/local/bin
COPY --from=render /usr/local/bin/render /usr/local/bin
COPY --from=golang /go/bin /usr/local/bin
RUN pip install yq