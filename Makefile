.PHONY: help base kops kubernetes node eb kong

GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)
TARGET_MAX_CHAR_NUM=20

help:
	@echo
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

## test semver script
test_semver:
	cd shared && bats ./tests

## build+test the base image
base:
	pipenv install
	pipenv run pytest -v Dockerfile_base_test.py	

## build the kops image
kops: kubernetes
	pipenv install
	pipenv run pytest -v Dockerfile_kops_test.py

## build the kubernetes image
kubernetes: node
	pipenv install
	pipenv run pytest -v Dockerfile_kubernetes_test.py

## build the node image
node:
	pipenv install
	pipenv run pytest -v Dockerfile_node_test.py

KONG_VERSION=2.3
## kong
kong:
	@echo "Building kong ${KONG_VERSION}"
	docker build --build-arg VERSION=${KONG_VERSION} -t samwyma/kong:${KONG_VERSION} ./kong
	docker push samwyma/kong:${KONG_VERSION}