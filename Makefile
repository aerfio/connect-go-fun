CURRENT_DIR = $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
export GOBIN=$(CURRENT_DIR)/bin

# Setting SHELL to bash allows bash commands to be executed by recipes.
# Options are set to exit when a recipe line exits non-zero or a piped command fails.
SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

.PHONY: all
all: binaries

BUF_VERSION = v1.32.2
BUF = ${CURRENT_DIR}bin/buf-${BUF_VERSION}
${BUF}:
	./hack/go-install-bin.sh "github.com/bufbuild/buf/cmd/buf" $(BUF_VERSION)

PROTOC_GEN_GO_VERSION = v1.34.1
PROTOC_GEN_GO = ${CURRENT_DIR}bin/protoc-gen-go-${PROTOC_GEN_GO_VERSION}
${PROTOC_GEN_GO}:
	./hack/go-install-bin.sh "google.golang.org/protobuf/cmd/protoc-gen-go" $(PROTOC_GEN_GO_VERSION)

# yolo, I know what the docs say, but goreleaser is doing essentially nothing unusual in golangci-lint's release pipeline and I always use newest Go version so we should be fine :shrug:
GOLANGCI_LINT_VERSION = v1.59.0
GOLANGCI_LINT = bin/golangci-lint-${GOLANGCI_LINT_VERSION}
${GOLANGCI_LINT}:
	./hack/go-install-bin.sh "github.com/golangci/golangci-lint/cmd/golangci-lint" $(GOLANGCI_LINT_VERSION)

PROTOC_GEN_CONNECT_GO_VERSION = v1.16.2
PROTOC_GEN_CONNECT_GO = bin/protoc-gen-connect-go-${PROTOC_GEN_CONNECT_GO_VERSION}
${PROTOC_GEN_CONNECT_GO}:
	./hack/go-install-bin.sh "connectrpc.com/connect/cmd/protoc-gen-connect-go" $(PROTOC_GEN_CONNECT_GO_VERSION)

GOFUMPT_VERSION = v0.6.0
GOFUMPT = bin/gofumpt-${GOFUMPT_VERSION}
${GOFUMPT}:
	./hack/go-install-bin.sh "mvdan.cc/gofumpt" $(GOFUMPT_VERSION)

GCI_VERSION = v0.13.4
GCI = bin/gci-${GCI_VERSION}
${GCI}:
	./hack/go-install-bin.sh "github.com/daixiang0/gci" $(GCI_VERSION)

.PHONY: binaries
binaries: ${BUF} ${PROTOC_GEN_GO} ${GOLANGCI_LINT} ${PROTOC_GEN_CONNECT_GO} ${GOFUMPT} ${GCI}

.PHONY: proto-lint
proto-lint: binaries
	$(BUF) lint

.PHONY: generate
generate: ${BUF} ${PROTOC_GEN_GO} ${PROTOC_GEN_CONNECT_GO}
	${BUF} generate

.PHONY: lint
lint: ${BUF}
	go vet ./...
	$(BUF) lint

.PHONY: format
format: ${BUF} ${GCI} ${GOFUMPT}
	$(GCI) write . --skip-generated -s standard -s default -s localmodule -s blank -s dot --custom-order --skip-vendor
	$(GOFUMPT) -w -extra -l .
	$(BUF) format -w

# https://ko.build/configuration/#local-publishing-options
.PHONY: ko-deploy-example
ko-deploy-example: export KO_DOCKER_REPO=kind.local
ko-deploy-example: export KOCACHE=$(CURRENT_DIR).kocache
ko-deploy-example:
	kubectl create ns aerfio --dry-run=client -oyaml | kubectl apply -f -
	ko apply -f ./k8s/yaml/ --sbom=none -B
