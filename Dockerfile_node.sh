#!/bin/bash

branch=$1

make node

if [ "$branch" == "master" ]; then
version=$(head -n 1 Dockerfile_node | grep -Po "FROM node:\K.+")
docker tag samwyma/ci-node "samwyma/ci-node:$version"
docker push samwyma/ci-node
docker push "samwyma/ci-node:$version"

# build for older versions of node
declare -a versions=("10" "12")

for version in "${versions[@]}"; do
sed "1cFROM node:$version-alpine" Dockerfile_node >"Dockerfile_node_$version"
docker build -t "samwyma/ci-node:$version" \
    --build-arg CRYPTOGRAPHY_DONT_BUILD_RUST=1 \
    -f "Dockerfile_node_$version" .
docker push "samwyma/ci-node:$version"
done
fi
