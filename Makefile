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

## test semver script
test_semver:
	cd shared && bats ./tests

## build+test the base image
base:
	pipenv install
	pipenv run pytest -v Dockerfile_base_test.py	

## build the kops image
kops: kubernetes
	docker build \
		--no-cache \
		--build-arg=VERSION=$(shell jq -r .kops version.json) \
		-t landtech/ci-kops \
		-f Dockerfile_kops .

## build the kubernetes image
kubernetes: node
	docker build \
		--no-cache \
		--build-arg=KUBECTL_VERSION=$(shell jq .kubectl version.json) \
		--build-arg=HELM_VERSION=$(shell jq .helm version.json) \
		--build-arg=AWS_IAM_AUTHENTICATOR_VERSION=$(shell jq .aws_iam_authenticator version.json) \
		--build-arg=ARGO_VERSION=$(shell jq .argo version.json) \
		--build-arg=RENDER_VERSION=$(shell jq .render version.json) \
		-t landtech/ci-kubernetes \
		-f Dockerfile_kubernetes .

## build the node image
node:
	pipenv install
	pipenv run pytest -v Dockerfile_node_test.py

## build+test the eb image, eg make eb version=3.17.1
eb:
	export version=${version}
	pipenv install
	pipenv run pytest -v Dockerfile_eb_test.py

