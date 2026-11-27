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

GO_VERSION     := 1.26.11
ALPINE_VERSION := 3.24
LINTER_VERSION := 2.15.0

YEAR_GEN := $(shell date '+%Y')

GOBIN := $(shell go env GOPATH)/bin
ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)
BUILD_DIR := $(ROOT_DIR)/.build
KPT_VERSION := $(shell date '+development-%Y-%m-%dT%H:%M:%S')

LDFLAGS := -ldflags "-X main.version=${KPT_VERSION}
ifeq ($(OS),Windows_NT)
	# Do nothing
else
    UNAME := $(shell uname -s)
    ifeq ($(UNAME),Linux)
        LDFLAGS += -extldflags '-z noexecstack'
    endif
endif
LDFLAGS += "

MODULES := api manager wrapper-server
