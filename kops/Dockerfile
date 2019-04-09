FROM landtech/ci-kubernetes:latest

ENV KOPS_VERSION=1.11.1

RUN curl -LO --silent --show-error https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-linux-amd64 \
  && mv kops-linux-amd64 /usr/local/bin/kops \
  && chmod +x /usr/local/bin/kops