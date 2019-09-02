# Docker CI Images

A selection of landtech CI docker images. 

## Building

Each image is built relative to the root and by specifying the path to the dockerfile. This allows us to share files among dockerfiles (e.g. core_deps.sh). E.g. `docker build -t landtech/ci-base -f base/Dockerfile .`

### Automated Builds

Automated Builds via [DockerHub](https://hub.docker.com/r/landtech) (credentials - `gopass hub.docker.com`). DockerHub is hooked up to our GitHub account, so triggers for all commits to this repo.
