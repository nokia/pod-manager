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

# Build from the repository root, because the module depends on ../api:
#   docker build -f manager/Dockerfile .

ARG GO_VERSION=1.26
ARG ALPINE_VERSION=3
# Registry mirror for Docker Hub images, e.g. --build-arg DOCKERHUB_MIRROR=mirror.example.com
ARG DOCKERHUB_MIRROR=docker.io

FROM --platform=$BUILDPLATFORM ${DOCKERHUB_MIRROR}/golang:${GO_VERSION} AS build
ARG TARGETOS
ARG TARGETARCH
# Optional Go module proxy and checksum database settings
ARG GOPROXY
ARG GOSUMDB
WORKDIR /src

COPY api api
COPY manager manager
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    cd manager && CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -trimpath -ldflags "-s -w" -o /out/manager .

FROM ${DOCKERHUB_MIRROR}/alpine:${ALPINE_VERSION}
RUN addgroup -g 10001 nonroot && \
    adduser -D -G nonroot -u 10001 nonroot
COPY --from=build --chown=nonroot:nonroot --chmod=500 /out/manager /manager
USER nonroot:nonroot
ENTRYPOINT ["/manager"]
