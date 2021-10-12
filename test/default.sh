#!/usr/bin/env bash

set -euo pipefail

# NOTE: This expects to be called from the root of the repo, so consider the
# working directory should be that.

./example.sh

echo '==='

# shellcheck disable=SC2038
find . -type f -name '*sh' -not -path './_/*' | xargs -t shellcheck -o all --

echo '==='

echo 'Starting BATS tests (https://github.com/bats-core/bats-core)…'
bats -r -T test/
