# Docker CI Images

A slim, carefully selected set of packages on top of the `docker:stable` image to reduce common repetition in build configs.

## Included

- `bash`
- `ca-certificates`
- `curl`
- `docker`
- `git`
- `jq`
- `make`
- `python3` [`awscli`, `pipenv`]
- `tar`
- `wget`

## Usage

[`landtech:ci-base`](https://hub.docker.com/u/landtech/ci-base) (built weekly and pushed to DockerHub)
