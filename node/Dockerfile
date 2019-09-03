FROM node:12.9.1-alpine

ENV PATH="./node_modules/.bin:${PATH}"

COPY ./shared/core_deps.sh core_deps.sh
RUN ./core_deps.sh && rm core_deps.sh

RUN apk update && apk add --no-cache \
  docker