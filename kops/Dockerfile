FROM landtech/ci-kubernetes:latest

ENV KOPS_VERSION=1.11.1

RUN curl -LO --silent --show-error https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-linux-amd64 \
  && mv kops-linux-amd64 /usr/local/bin/kops \
  && chmod +x /usr/local/bin/kops

# Go
RUN apk add --no-cache musl-dev go gcc
ENV GOROOT /usr/lib/go
ENV GOPATH /go
ENV PATH /go/bin:$PATH
RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin

RUN go get github.com/google/go-jsonnet/cmd/jsonnet \
  && go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb \
  && go get github.com/brancz/gojsontoyaml \
  && go get github.com/VirtusLab/render

RUN pip install yq