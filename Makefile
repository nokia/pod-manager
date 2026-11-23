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

.PHONY: build manager/build wrapper-server/build
manager/build:
	$(MAKE) -C manager build

wrapper-server/build:
	$(MAKE) -C wrapper-server build

build: manager/build wrapper-server/build

.PHONY: lint manager/lint wrapper-server/lint
manager/lint:
	$(MAKE) -C manager lint

wrapper-server/lint:
	$(MAKE) -C wrapper-server lint

lint: manager/lint wrapper-server/lint
