# CI Kubernetes

[`landtech/ci-kubernetes`](https://hub.docker.com/u/landtech/ci-kubernetes) - an image for deploying kubernetes applications via ci. It's built on top of landtech/ci-base.

## Included

- `helm`
- `kubectl`
- `aws-iam-authenticator`
- `credstash` (and it's [dependencies](https://github.com/fugue/credstash#linux-install-time-dependencies))
- `yq`

## Builds

Automated Builds via DockerHub (for all commits and base image changes), see the [project page](https://hub.docker.com/r/landtech/ci-kubernetes)