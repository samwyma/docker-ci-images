# Docker CI Images

Docker images used for CI, built nightly.

## Core Dependencies

`shared/core_deps.sh` - a slim, **carefully chosen** set of packages applied to an image to reduce common repetition in build configs. It exists so we can have common dependencies applied to differing base images.

- `bash`
- `bats`
- `ca-certificates`
- `credstash`
- `curl`
- `docker`
- `git`
- `grep`
- `jq`
- `lsof`
- `make`
- `python3` [`awscli`, `pipenv`, `credstash`]
- `tar`
- `wget`
- `zip`
- `util-linux`

## Running Locally

```bash
make help
...
```

### Builds

- Builds run nightly via CircleCI
- Pushed to our Docker Hub [`landtech`](https://hub.docker.com/u/landtech) organisation
