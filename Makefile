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

SHELL := bash
.SHELLFLAGS := -exc

include make/info.mk

.PHONY: all build lint test
.PHONY: $(addsuffix /all,$(MODULES)) $(addsuffix /build,$(MODULES)) $(addsuffix /lint,$(MODULES)) $(addsuffix /test,$(MODULES)) $(addsuffix /tidy,$(MODULES))

$(addsuffix /all,$(MODULES)): %/all:
	$(MAKE) -C $* all

$(addsuffix /build,$(MODULES)): %/build:
	$(MAKE) -C $* build

$(addsuffix /test,$(MODULES)): %/test:
	$(MAKE) -C $* test

$(addsuffix /lint,$(MODULES)): %/lint:
	$(MAKE) -C $* lint

$(addsuffix /tidy,$(MODULES)): %/tidy:
	$(MAKE) -C $* tidy

build: $(addsuffix /build,$(MODULES))

lint: $(addsuffix /lint,$(MODULES))

test: $(addsuffix /test,$(MODULES))

tidy: $(addsuffix /tidy,$(MODULES))

.PHONY: api/generate generate
api/generate:
	$(MAKE) -C api generate

generate: api/generate

include make/docker.mk
