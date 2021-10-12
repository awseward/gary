#!/usr/bin/env bash

set -euo pipefail

# NOTE: This expects to be called from the root of the repo, so consider the
# working directory should be that.

./example.sh

echo '==='

# shellcheck disable=SC2038
find . -type f -name '*sh' -not -path './_/*' | xargs -t shellcheck -o all --

echo '==='

dhall to-directory-tree --output test/libdeploy/ <<< ./test/libdeploy/check_fmode.bats.dhall

bats -T test/libdeploy/prune.bats

# This is commented out because it takes ~45s to run
# TODO: Fit this into some kind of "expensive" tests scheme that can be run
# less frequently
# bats -T test/libdeploy/check_fmode.bats
