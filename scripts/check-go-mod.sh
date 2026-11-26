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

# Checks that the go.mod in a directory is fit to be released:
#   - it has no replace directives, except for the allowed modules
#   - it requires no pseudo-versions of github.com/kptdev/* modules
#
# Usage: check-go-mod.sh <module-dir> [allowed-replaced-module...]
#
# Adapted from the check-go-mod-replace action in kptdev/kpt.
# TODO: use that action directly once it also rejects pseudo-versions.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <module-dir> [allowed-replaced-module...]" >&2
  exit 2
fi

dir=$1
shift
allowed=$(printf '%s\n' "$@" | jq -R . | jq -s .)

modfile=$(cd "$dir" && go mod edit -json)

replaces=$(jq --argjson allowed "$allowed" \
  '[(.Replace // [])[] | select(.Old.Path as $p | $allowed | index($p) | not)]' <<<"$modfile")

# A pseudo-version ends in -<yyyymmddhhmmss>-<12 hex chars>, optionally with +incompatible.
pseudo=$(jq '[(.Require // [])[]
  | select(.Path | startswith("github.com/kptdev/"))
  | select(.Version | test("-[0-9]{14}-[0-9a-f]{12}(\\+incompatible)?$"))]' <<<"$modfile")

failed=0
if [[ $(jq length <<<"$replaces") -gt 0 ]]; then
  echo "::error::$dir/go.mod contains unexpected replace directives:"
  jq . <<<"$replaces"
  failed=1
fi
if [[ $(jq length <<<"$pseudo") -gt 0 ]]; then
  echo "::error::$dir/go.mod requires pseudo-versions of github.com/kptdev modules:"
  jq . <<<"$pseudo"
  failed=1
fi

exit "$failed"
