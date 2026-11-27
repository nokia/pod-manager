#!/usr/bin/env bash
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

# Prepares a lock-step release locally, without pushing anything.
#
# main keeps its replace directives (api => ../api). For a release, this script:
#   1. tags the current commit as api/<version>,
#   2. creates a release commit on top of it that drops the replace directives and
#      requires api@<version> in manager and wrapper-server,
#   3. verifies that commit (no replaces, no pseudo-versions, build, lint, test),
#   4. tags it as manager/<version>, wrapper-server/<version> and <version>.
#
# The api tag is resolved from the local repository, never through the Go module
# proxy. Once the proxy has seen a version it remembers it forever, even if the tag
# is deleted later, so nothing may become visible before the release is verified.
# The caller pushes the tags, e.g. git push --atomic origin <the four tags>.
#
# With --dry-run, the repository is restored afterwards (the tags are deleted again).
#
# Usage: prepare-release.sh [--dry-run] <version>
# Needs a git identity (user.name and user.email) to create the release commit.

set -euo pipefail

dry_run=false
if [[ ${1:-} == "--dry-run" ]]; then
  dry_run=true
  shift
fi
if [[ $# -ne 1 ]]; then
  echo "usage: $0 [--dry-run] <version>" >&2
  exit 2
fi
version=$1

root=$(git rev-parse --show-toplevel)
cd "$root"
if [[ -n "$(git status --porcelain)" ]]; then
  echo "::error::The working tree must be clean"
  exit 1
fi

base=$(git rev-parse HEAD)
orig_branch=$(git symbolic-ref -q --short HEAD || true)
tags=("api/$version" "manager/$version" "wrapper-server/$version" "$version")
api=github.com/kptdev/pod-manager/api

# Go caches the api version it resolved from the local repository. Drop it, so a
# local run does not leave a version in the module cache that does not match the
# published one.
cleanup() {
  modcache=$(go env GOMODCACHE)
  chmod -R u+w "$modcache/$api@$version" 2>/dev/null || true
  rm -rf "$modcache/$api@$version" "$modcache"/cache/download/"$api"/@v/"$version".*
  if [[ "$dry_run" == true ]]; then
    git switch -q --detach "$base"
    for tag in "${tags[@]}"; do
      git tag -d "$tag" >/dev/null 2>&1 || true
    done
    if [[ -n "$orig_branch" ]]; then
      git switch -q "$orig_branch"
    fi
  fi
}
trap cleanup EXIT

git tag "api/$version" "$base"
git switch -q --detach

for module in manager wrapper-server; do
  (cd "$module" && go mod edit -dropreplace="$api" -require="$api@$version")
done

# Resolve the pod-manager modules with git from this repository instead of the
# proxy. Other modules still come from the proxy. The module path is always
# github.com/kptdev/pod-manager, also when this runs in another repository,
# where the tags only exist locally.
export GIT_CONFIG_COUNT=1
export GIT_CONFIG_KEY_0="url.file://$root.insteadOf"
export GIT_CONFIG_VALUE_0="https://github.com/kptdev/pod-manager"
export GOPROXY=https://proxy.golang.org,direct
export GONOPROXY='github.com/kptdev/pod-manager/*'
export GONOSUMDB='github.com/kptdev/pod-manager/*'
export GOFLAGS=-modcacherw
make tidy
unset GIT_CONFIG_COUNT GIT_CONFIG_KEY_0 GIT_CONFIG_VALUE_0 GONOPROXY GONOSUMDB GOFLAGS

git add manager/go.mod manager/go.sum wrapper-server/go.mod wrapper-server/go.sum
git commit -q -m "Release $version"
git diff --stat "$base" HEAD

for module in api manager wrapper-server; do
  scripts/check-go-mod.sh "$module"
done
make build
make lint
make test

for tag in "${tags[@]:1}"; do
  git tag "$tag"
done

summary() {
  local kind="release"
  local image_tags="\`$version\`, \`stable\`"
  if [[ "$version" == *-pre.* ]]; then
    kind="pre-release"
    image_tags="\`$version\`"
  fi
  echo "## Release $version ($kind)"
  echo
  if [[ "$dry_run" == true ]]; then
    echo "Dry run: nothing is pushed. A real run would do the following."
  else
    echo "Verified. The following is pushed next."
  fi
  echo
  echo "### Tags"
  echo
  echo "- \`api/$version\` on \`$base\` (the commit on main)"
  for tag in "${tags[@]:1}"; do
    echo "- \`$tag\` on \`$(git rev-parse HEAD)\` (the release commit, not on any branch)"
  done
  echo
  echo "### Release commit changes"
  echo
  echo '```diff'
  git diff "$base" HEAD -- '*.mod'
  echo '```'
  echo
  echo "### Published by goreleaser"
  echo
  local owner=${GITHUB_REPOSITORY_OWNER:-kptdev}
  owner=${owner,,}
  echo "- Images: \`ghcr.io/$owner/pod-manager\` and \`ghcr.io/$owner/wrapper-server\` (linux/amd64, linux/arm64), tags $image_tags"
  echo "- Binaries and checksums for \`pod-manager\` and \`wrapper-server\`: linux and darwin, amd64 and arm64"
  echo "- GitHub release \`$version\` ($kind), notes generated by GitHub"
}
summary
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  summary >> "$GITHUB_STEP_SUMMARY"
fi

echo "Prepared release commit $(git rev-parse HEAD) with tags: ${tags[*]}"
