.PHONY: help base kops kubernetes node eb

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


## build+test the base image
base:
	pipenv install -d
	pipenv run pytest -v Dockerfile_base_test.py	

## build the kops image
kops:
	docker build \
		--build-arg=VERSION=${version} \
		-t landtech/ci-kops \
		-f Dockerfile_kops .

## build the kubernetes image
kubernetes:
	docker build \
		-t landtech/ci-kubernetes \
		-f Dockerfile_kubernetes .

## build the node image
node:
	docker build \
		-t landtech/ci-node \
		-f Dockerfile_node .

## build+test the eb image
eb:
	pipenv install -d
	pipenv run pytest -v Dockerfile_eb_test.py
	docker build \
		--build-arg=VERSION=${version} \
		-t landtech/ci-eb \
		-f Dockerfile_eb .
