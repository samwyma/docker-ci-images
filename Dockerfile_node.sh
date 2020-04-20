#!/bin/bash

branch=$1

make node

if [ "$branch" == "master" ]; then
    version=$(head -n 1 Dockerfile_node | grep -Po "FROM node:\K.+")
    docker tag landtech/ci-node "landtech/ci-node:$version"
    docker push landtech/ci-node
    docker push "landtech/ci-node:$version"

    # build for older versions of node
    declare -a versions=("10" "12")

    for version in "${versions[@]}"; do
        sed "1cFROM node:$version-alpine" Dockerfile_node >"Dockerfile_node_$version"
        docker build -t "landtech/ci-node:$version" -f "Dockerfile_node_$version" .
        docker push "landtech/ci-node:$version"
    done
fi
