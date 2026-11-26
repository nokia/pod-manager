# Copyright 2026 The kpt Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Shared Go module targets. Each module Makefile sets MOD_TYPE (bin or lib) and
# then includes this file.

SHELL := bash
.SHELLFLAGS := -exc

include $(ROOT_DIR)/make/info.mk

ifeq ($(filter $(MOD_TYPE),bin lib),)
$(error MOD_TYPE must be "bin" or "lib", got "$(MOD_TYPE)")
endif
ifeq ($(MOD_TYPE),bin)
# The binary is named after the module directory by default (like wrapper-server),
# which can be overridden by the module's Makefile (like manager ~> pod-manager).
BIN_NAME ?= $(notdir $(CURDIR))
endif

.PHONY: all
all: fix vet fmt lint test tidy

.PHONY: fix
fix:
	go fix ./...

.PHONY: fmt
fmt:
	go fmt ./...

.PHONY: tidy
tidy:
	go mod tidy

# if the local version of golangci-lint matches the one we want, we can use that without overhead
.PHONY: lint
lint:
	@if [[ `command -v golangci-lint` && `golangci-lint version --short` == $(LINTER_VERSION) ]]; then \
		golangci-lint run -v ./...; \
	else \
		go run github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v$(LINTER_VERSION) run -v ./...; \
	fi

.PHONY: test
test:
	go test -cover ${LDFLAGS} ./...

.PHONY: vet
vet:
	go vet ./...

# bin: build the binary named after the module directory.
# lib: nothing to link, so only check that every package compiles.
.PHONY: build
build:
ifeq ($(MOD_TYPE),bin)
	go build ${LDFLAGS} -o $(BUILD_DIR)/$(BIN_NAME) -v .
else
	go build ./...
endif
