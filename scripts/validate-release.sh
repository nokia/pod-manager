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

# Validates a release version before anything is tagged:
#   - it looks like vX.Y.Z or vX.Y.Z-pre.N (see VERSIONING.md in kptdev/governance)
#   - the release tags do not exist yet
#   - it is newer than every existing release
#   - the current commit is on main (patch releases from release-X.Y branches are
#     not supported yet)
#   - the "go" check passed on the current commit (needs the gh CLI and GH_TOKEN)
#
# Usage: validate-release.sh [--skip-ci-check] <version>
#
# Prints "previous=<latest existing release tag>" (empty if there is none), and
# also appends it to $GITHUB_OUTPUT when that is set.

set -euo pipefail

skip_ci_check=false
if [[ ${1:-} == "--skip-ci-check" ]]; then
  skip_ci_check=true
  shift
fi
if [[ $# -ne 1 ]]; then
  echo "usage: $0 [--skip-ci-check] <version>" >&2
  exit 2
fi
version=$1

fail() {
  echo "::error::$*"
  exit 1
}

# "~" sorts before everything in sort -V, so v1.2.3-pre.1 is older than v1.2.3.
sortable() { echo "${1/-pre./~pre.}"; }

branch=${GITHUB_REF_NAME:-$(git symbolic-ref -q --short HEAD || true)}
if [[ "$branch" != "main" ]]; then
  fail "Releases must be started from main, not '${branch:-a detached HEAD}'"
fi

if [[ ! "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-pre\.[0-9]+)?$ ]]; then
  fail "Version '$version' must look like v1.2.3 or v1.2.3-pre.1"
fi

for tag in "$version" "api/$version" "manager/$version" "wrapper-server/$version"; do
  if git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
    fail "Tag $tag already exists"
  fi
done

previous=$(git tag --list 'v[0-9]*' | while read -r tag; do sortable "$tag"; done | sort -V | tail -n 1)
previous=${previous/~pre./-pre.}
if [[ -n "$previous" ]]; then
  newest=$(printf '%s\n%s\n' "$(sortable "$previous")" "$(sortable "$version")" | sort -V | tail -n 1)
  if [[ "$newest" != "$(sortable "$version")" ]]; then
    fail "$version is not newer than the latest release $previous"
  fi
fi

if [[ "$skip_ci_check" == false ]]; then
  sha=$(git rev-parse HEAD)
  repo=${GITHUB_REPOSITORY:-$(gh repo view --json nameWithOwner --jq .nameWithOwner)}
  # "<status> <conclusion>" of the check run named go, empty if there is none.
  check=$(gh api "repos/$repo/commits/$sha/check-runs" \
    --jq '[.check_runs[] | select(.name == "go")][0] // empty | "\(.status) \(.conclusion)"')
  if [[ -z "$check" ]]; then
    fail "No check named 'go' has been reported on $sha. The check was renamed (see the go-gate job in go.yml), skipped, or has not started yet. Wait for the Go workflow on main to finish, or rerun it."
  fi
  read -r status conclusion <<<"$check"
  if [[ "$status" != "completed" ]]; then
    fail "The 'go' check on $sha has not finished yet (status '$status'). Wait for it to pass."
  fi
  if [[ "$conclusion" != "success" ]]; then
    fail "The 'go' check on $sha concluded '$conclusion', expected 'success'"
  fi
fi

echo "previous=$previous"
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "previous=$previous" >> "$GITHUB_OUTPUT"
fi
