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

# Container image builds. Images are built from the repository root because
# each module depends on the sibling api module.

# Optional local settings (mirrors, Go proxy). Values may be quoted.
ifneq ("$(wildcard $(ROOT_DIR)/.env)", "")
    include $(ROOT_DIR)/.env
    export
endif

export DOCKERHUB_MIRROR ?= docker.io
export DOCKERHUB_MIRROR := $(patsubst %/,%,$(subst ",,$(DOCKERHUB_MIRROR)))
export GOPROXY := $(subst ",,$(GOPROXY))
export GOSUMDB := $(subst ",,$(GOSUMDB))

IMAGE_PREFIX ?= ghcr.io/kptdev
IMAGE_TAG ?= dev
DOCKER ?= docker
# Set DOCKER_NETWORK_HOST=true to build with host networking (e.g. behind a proxy)
DOCKER_NETWORK_HOST ?= false

DOCKER_BUILD_ARGS := \
	--build-arg 'DOCKERHUB_MIRROR=$(DOCKERHUB_MIRROR)' \
	--build-arg 'GOPROXY=$(GOPROXY)' \
	--build-arg 'GOSUMDB=$(GOSUMDB)'
ifneq ($(filter 1 true TRUE True,$(DOCKER_NETWORK_HOST)),)
    DOCKER_BUILD_ARGS += --network host
endif

IMAGES := pod-manager wrapper-server

.PHONY: images $(addsuffix /image,$(IMAGES))

$(addsuffix /image,$(IMAGES)): %/image:
	$(DOCKER) build $(DOCKER_BUILD_ARGS) \
		-f $(ROOT_DIR)/$(if $(filter pod-manager,$*),manager,$*)/Dockerfile \
		-t $(IMAGE_PREFIX)/$*:$(IMAGE_TAG) $(ROOT_DIR)

images: $(addsuffix /image,$(IMAGES))
