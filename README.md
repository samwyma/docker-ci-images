# Docker CI Images

Docker images used for CI

## Running Locally

```
make test
make build folder=base
make build folder=node
...
```

Each image is built relative to the root and by specifying the path to the dockerfile. This allows us to share files among dockerfiles (e.g. core_deps.sh).

### Automated Builds

Builds run nightly via CircleCI
